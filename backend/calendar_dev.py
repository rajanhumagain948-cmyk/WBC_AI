from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.calendar import initialize_calendar_db
from app.api.calendar import router as calendar_router


@asynccontextmanager
async def lifespan(_app: FastAPI):
    initialize_calendar_db()
    yield


app = FastAPI(
    title="WBC AI Calendar",
    description="Development server for the school calendar",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(calendar_router)
