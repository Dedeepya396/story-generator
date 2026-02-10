from fastapi import FastAPI
from app.routes.video import router as video_router

app = FastAPI(title="Story Video Generator")

app.include_router(video_router)

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)