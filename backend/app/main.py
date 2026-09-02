from fastapi import FastAPI
from app.routes.videoRoute import router as video_router
from app.routes.userRoute import router as users
from app.routes.characterRoute import router as character_router
from app.routes.storyRoute import router as story_router
from app.routes.video import router as video_generate_router
from app.routes.chatbotRoute import router as chatbot_router
# from services.quiz_service import generate_quiz_from_story
from app.routes.quizRoute import router as generate_quiz
app = FastAPI(title="Story Video Generator")
app.include_router(video_router)
app.include_router(users)
app.include_router(character_router)
app.include_router(story_router)
app.include_router(video_generate_router) 
app.include_router(chatbot_router)
app.include_router(generate_quiz)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
import logging

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    print(f"\n[SIGNUP/VALIDATION ERROR] URL: {request.url}")
    print(f"[SIGNUP/VALIDATION ERROR] Details: {exc.errors()}\n")
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors()},
    )