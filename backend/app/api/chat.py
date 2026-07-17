from fastapi import APIRouter
from pydantic import BaseModel

from app.services.chat_service import ask

router = APIRouter()


class ChatRequest(BaseModel):
    question: str
    language: str = "日本語"  # デフォルトは日本語


@router.post("/chat")
def chat(request: ChatRequest):
    result = ask(request.question, request.language)
    return result