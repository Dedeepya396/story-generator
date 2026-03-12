from fastapi import APIRouter
from app.schemas.chatbotRequest import StoryRequest, StoryResponse
from app.services.chatbot_service import generate_story

router = APIRouter(prefix="/story", tags=["AI Story"])


@router.post("/generate_story", response_model=StoryResponse)
async def generate_story_route(req: StoryRequest):

    story = await generate_story(
        prompt=req.prompt,
        genre=req.genre
    )

    return {"story": story}