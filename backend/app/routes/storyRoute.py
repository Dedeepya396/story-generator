from typing import List
from fastapi import APIRouter, HTTPException
from app.schemas.storySchema import StoryCreate, StoryOut
from app.services.story_service import create_story, get_story_by_id, list_stories_by_user

router = APIRouter(prefix="/stories", tags=["stories"])

@router.post("/", response_model=StoryOut)
async def create_story_endpoint(payload: StoryCreate):
    created = await create_story(payload)
    return created

@router.get("/{story_id}", response_model=StoryOut)
async def get_story_endpoint(story_id: str):
    story = await get_story_by_id(story_id)
    if not story:
        raise HTTPException(status_code=404, detail="Story not found")
    return story

@router.get("/user/{user_id}", response_model=List[StoryOut])
async def list_user_stories(user_id: str):
    return await list_stories_by_user(user_id)