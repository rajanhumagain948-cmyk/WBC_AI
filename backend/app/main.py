from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.chat import router as chat_router

app = FastAPI(
    title="WBC AI",
    description="WBC AI School Assistant",
    version="1.0.0"
)

# ブラウザからのアクセスを許可(開発用設定)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router)


@app.get("/")
def home():
    return {
        "message": "Welcome to WBC AI!"
    }