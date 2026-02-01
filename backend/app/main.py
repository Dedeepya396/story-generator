from fastapi import FastAPI
from app.routes.video import router as video_router

app = FastAPI(title="Story Video Generator")

app.include_router(video_router)
