from __future__ import annotations

import base64
import binascii
import hashlib
import hmac
import json
import os
import sqlite3
import time
from collections.abc import Iterator
from contextlib import contextmanager
from datetime import date, datetime, timezone
from pathlib import Path
from threading import Lock
from typing import Any

from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field, field_validator, model_validator

BACKEND_DIR = Path(__file__).resolve().parents[2]
load_dotenv(BACKEND_DIR / ".env")

DB_PATH = Path(
    os.getenv("CALENDAR_DB_PATH", str(BACKEND_DIR / "data" / "calendar.sqlite3"))
).expanduser()

TOKEN_TTL_SECONDS = 8 * 60 * 60
LOGIN_WINDOW_SECONDS = 15 * 60
LOGIN_MAX_FAILURES = 5

router = APIRouter(prefix="/calendar", tags=["calendar"])
_bearer = HTTPBearer(auto_error=False)
_login_failures: dict[str, list[float]] = {}
_login_lock = Lock()

# 写真から日付と内容を確認できた予定だけを初回データとして登録します。
# 写真から確定できない9月19〜23日の予定は登録していません。
_INITIAL_EVENTS = [
    ("2026-09-01", "2026-09-01", "授業開始", ""),
    ("2026-09-14", "2026-09-18", "前期期末試験", ""),
    ("2026-09-21", "2026-09-21", "敬老の日", ""),
    ("2026-09-22", "2026-09-22", "国民の休日", ""),
    ("2026-09-23", "2026-09-23", "秋分の日", ""),
    ("2026-09-24", "2026-09-30", "前期期末試験（PC系科目）", ""),
    ("2026-10-05", "2026-10-05", "後期開始", ""),
    ("2026-10-12", "2026-10-12", "スポーツの日", ""),
    ("2026-10-15", "2026-10-15", "卒業旅行①（2年生）", ""),
    ("2026-10-20", "2026-10-20", "卒業旅行②（2年生）", ""),
    ("2026-11-03", "2026-11-03", "文化の日", ""),
    ("2026-11-16", "2026-11-20", "後期中間試験", ""),
    ("2026-11-23", "2026-11-23", "勤労感謝の日", ""),
    ("2026-12-03", "2026-12-03", "国際文化交流会", ""),
    ("2026-12-07", "2026-12-11", "クリスマス会（予定期間）", ""),
    ("2026-12-18", "2026-12-18", "年内最終授業日", ""),
    ("2026-12-21", "2027-01-06", "冬休み", ""),
    ("2027-01-07", "2027-01-07", "新年の授業開始", ""),
]


@contextmanager
def _connection() -> Iterator[sqlite3.Connection]:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    connection = sqlite3.connect(str(DB_PATH), timeout=10)
    connection.row_factory = sqlite3.Row

    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def initialize_calendar_db() -> None:
    """テーブル作成と初回予定の登録。アプリ起動時に呼び出します。"""
    with _connection() as connection:
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS calendar_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                start_date TEXT NOT NULL,
                end_date TEXT NOT NULL,
                title TEXT NOT NULL,
                details TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
            """
        )
        connection.execute(
            """
            CREATE INDEX IF NOT EXISTS idx_calendar_events_dates
            ON calendar_events (start_date, end_date)
            """
        )
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS calendar_meta (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )
            """
        )

        seeded = connection.execute(
            "SELECT value FROM calendar_meta WHERE key = ?",
            ("initial_events_v1",),
        ).fetchone()

        if seeded is None:
            now = datetime.now(timezone.utc).isoformat(timespec="seconds")
            connection.executemany(
                """
                INSERT INTO calendar_events
                    (start_date, end_date, title, details, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                [
                    (start, end, title, details, now, now)
                    for start, end, title, details in _INITIAL_EVENTS
                ],
            )
            connection.execute(
                "INSERT INTO calendar_meta (key, value) VALUES (?, ?)",
                ("initial_events_v1", "done"),
            )


class CalendarEventInput(BaseModel):
    start_date: date
    end_date: date
    title: str = Field(min_length=1, max_length=100)
    details: str = Field(default="", max_length=500)

    @field_validator("title")
    @classmethod
    def clean_title(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("予定名を入力してください。")
        return value

    @field_validator("details")
    @classmethod
    def clean_details(cls, value: str) -> str:
        return value.strip()

    @model_validator(mode="after")
    def validate_date_range(self) -> CalendarEventInput:
        if self.end_date < self.start_date:
            raise ValueError("終了日は開始日以降にしてください。")
        return self


class AdminLoginInput(BaseModel):
    password: str = Field(min_length=1, max_length=256)


def _token_secret() -> str:
    secret = os.getenv("CALENDAR_TOKEN_SECRET", "")
    if len(secret) < 32:
        raise HTTPException(
            status_code=503,
            detail="管理者認証が設定されていません。",
        )
    return secret


def _b64url_encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).decode("ascii").rstrip("=")


def _b64url_decode(value: str) -> bytes:
    padding = "=" * ((-len(value)) % 4)
    return base64.urlsafe_b64decode(value + padding)


def _create_admin_token(secret: str) -> str:
    payload = {
        "sub": "calendar-admin",
        "exp": int(time.time()) + TOKEN_TTL_SECONDS,
    }
    payload_part = _b64url_encode(
        json.dumps(payload, separators=(",", ":")).encode("utf-8")
    )
    signature = hmac.new(
        secret.encode("utf-8"),
        payload_part.encode("ascii"),
        hashlib.sha256,
    ).digest()
    return f"{payload_part}.{_b64url_encode(signature)}"


def require_admin(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> None:
    secret = _token_secret()

    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=401,
            detail="管理者ログインが必要です。",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload_part, signature_part = credentials.credentials.split(".", 1)
        expected_signature = hmac.new(
            secret.encode("utf-8"),
            payload_part.encode("ascii"),
            hashlib.sha256,
        ).digest()
        supplied_signature = _b64url_decode(signature_part)

        if not hmac.compare_digest(expected_signature, supplied_signature):
            raise ValueError("signature mismatch")

        payload: dict[str, Any] = json.loads(
            _b64url_decode(payload_part).decode("utf-8")
        )
        if (
            payload.get("sub") != "calendar-admin"
            or int(payload.get("exp", 0)) <= int(time.time())
        ):
            raise ValueError("expired or invalid token")
    except (
        ValueError,
        TypeError,
        KeyError,
        UnicodeDecodeError,
        binascii.Error,
    ):
        raise HTTPException(
            status_code=401,
            detail="管理者ログインの有効期限が切れました。再ログインしてください。",
            headers={"WWW-Authenticate": "Bearer"},
        ) from None


@router.post("/admin/login")
def admin_login(payload: AdminLoginInput, request: Request) -> dict[str, Any]:
    admin_password = os.getenv("CALENDAR_ADMIN_PASSWORD", "")
    secret = _token_secret()

    if len(admin_password) < 12:
        raise HTTPException(
            status_code=503,
            detail="管理者パスワードが設定されていません。",
        )

    client_ip = request.client.host if request.client else "unknown"
    now = time.monotonic()

    with _login_lock:
        # 古い失敗記録を消し、同じIPからの連続試行を制限します。
        for ip, attempts in list(_login_failures.items()):
            recent = [
                attempt
                for attempt in attempts
                if now - attempt < LOGIN_WINDOW_SECONDS
            ]
            if recent:
                _login_failures[ip] = recent
            else:
                _login_failures.pop(ip, None)

        attempts = _login_failures.get(client_ip, [])
        if len(attempts) >= LOGIN_MAX_FAILURES:
            raise HTTPException(
                status_code=429,
                detail="ログイン試行が多すぎます。しばらく待ってから再試行してください。",
            )

        password_matches = hmac.compare_digest(
            payload.password.encode("utf-8"),
            admin_password.encode("utf-8"),
        )
        if not password_matches:
            _login_failures[client_ip] = [*attempts, now]
            raise HTTPException(
                status_code=401,
                detail="パスワードが正しくありません。",
            )

        _login_failures.pop(client_ip, None)

    return {
        "access_token": _create_admin_token(secret),
        "token_type": "bearer",
        "expires_in": TOKEN_TTL_SECONDS,
    }


@router.get("/events")
def list_events(
    year: int = Query(..., ge=1900, le=2100),
) -> list[dict[str, Any]]:
    year_start = f"{year:04d}-01-01"
    year_end = f"{year:04d}-12-31"

    with _connection() as connection:
        rows = connection.execute(
            """
            SELECT id, start_date, end_date, title, details, updated_at
            FROM calendar_events
            WHERE start_date <= ? AND end_date >= ?
            ORDER BY start_date, title, id
            """,
            (year_end, year_start),
        ).fetchall()

    return [dict(row) for row in rows]


@router.post("/events", status_code=201)
def create_event(
    payload: CalendarEventInput,
    _admin: None = Depends(require_admin),
) -> dict[str, Any]:
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")

    with _connection() as connection:
        cursor = connection.execute(
            """
            INSERT INTO calendar_events
                (start_date, end_date, title, details, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                payload.start_date.isoformat(),
                payload.end_date.isoformat(),
                payload.title,
                payload.details,
                now,
                now,
            ),
        )
        event_id = cursor.lastrowid

    return {
        "id": event_id,
        "start_date": payload.start_date.isoformat(),
        "end_date": payload.end_date.isoformat(),
        "title": payload.title,
        "details": payload.details,
        "updated_at": now,
    }


@router.put("/events/{event_id}")
def update_event(
    event_id: int,
    payload: CalendarEventInput,
    _admin: None = Depends(require_admin),
) -> dict[str, Any]:
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")

    with _connection() as connection:
        cursor = connection.execute(
            """
            UPDATE calendar_events
            SET start_date = ?, end_date = ?, title = ?, details = ?, updated_at = ?
            WHERE id = ?
            """,
            (
                payload.start_date.isoformat(),
                payload.end_date.isoformat(),
                payload.title,
                payload.details,
                now,
                event_id,
            ),
        )
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="予定が見つかりません。")

    return {
        "id": event_id,
        "start_date": payload.start_date.isoformat(),
        "end_date": payload.end_date.isoformat(),
        "title": payload.title,
        "details": payload.details,
        "updated_at": now,
    }


@router.delete("/events/{event_id}")
def delete_event(
    event_id: int,
    _admin: None = Depends(require_admin),
) -> dict[str, bool]:
    with _connection() as connection:
        cursor = connection.execute(
            "DELETE FROM calendar_events WHERE id = ?",
            (event_id,),
        )
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="予定が見つかりません。")

    return {"deleted": True}
