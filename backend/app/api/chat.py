from fastapi import APIRouter
from pydantic import BaseModel

from app.services.chat_service import ask

router = APIRouter()


class ChatRequest(BaseModel):
    question: str


@router.post("/chat")
def chat(request: ChatRequest):
    result = ask(request.question)
    return result