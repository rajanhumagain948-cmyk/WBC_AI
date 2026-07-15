from fastapi import FastAPI

from app.api.chat import router as chat_router

app = FastAPI(
    title="WBC AI",
    description="WBC AI School Assistant",
    version="1.0.0"
)

app.include_router(chat_router)


@app.get("/")
def home():
    return {
        "message": "Welcome to WBC AI!"
    }