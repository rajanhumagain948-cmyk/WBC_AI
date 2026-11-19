from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.calendar import initialize_calendar_db
from app.api.calendar import router as calendar_router
from app.api.chat import router as chat_router


@asynccontextmanager
async def lifespan(_app: FastAPI):
    initialize_calendar_db()
    yield


app = FastAPI(
    title="WBC AI",
    description="WBC AI School Assistant",
    version="1.0.0",
    lifespan=lifespan,
)

# ブラウザからのアクセスを許可する開発用設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat_router)
app.include_router(calendar_router)


@app.get("/")
def home():
    return {"message": "Welcome to WBC AI!"}
