from typing import List
from fastapi import APIRouter, HTTPException
from app.schemas.videoSchema import VideoCreate, VideoOut
from app.services.videocreation_service import create_video_entry, get_video_by_id, list_videos_by_story

router = APIRouter(prefix="/videos", tags=["videos"])

@router.post("/", response_model=VideoOut)
async def create_video_endpoint(payload: VideoCreate):
    created = await create_video_entry(payload)
    return created

@router.get("/{video_id}", response_model=VideoOut)
async def get_video_endpoint(video_id: str):
    v = await get_video_by_id(video_id)
    if not v:
        raise HTTPException(status_code=404, detail="Video not found")
    return v

@router.get("/story/{story_id}", response_model=List[VideoOut])
async def list_videos_for_story(story_id: str):
    return await list_videos_by_story(story_id)