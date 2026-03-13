from typing import List
from fastapi import APIRouter, HTTPException
from app.schemas.storySchema import StoryCreate, StoryOut
from app.services.story_service import create_story, get_story_by_id, list_stories_by_user, list_public_stories, delete_story_by_id
from app.services.indic_translation_service import get_supported_languages
from app.services.videoUpload import delete_video_from_cloudinary, delete_image_from_cloudinary


router = APIRouter(prefix="/stories", tags=["stories"])

@router.get("/languages")
async def get_languages():
    """Get list of supported input and output languages"""
    languages = get_supported_languages()
    return {
        "input_languages": languages,
        "output_languages": languages,
        "count": len(languages)
    }


@router.post("/", response_model=StoryOut)
async def create_story_endpoint(payload: StoryCreate):
    created = await create_story(payload)
    return created

@router.get("/public", response_model=List[StoryOut])
async def list_public_stories_endpoint():
    """
    Returns public stories (displayFlag == True).
    """
    print("Listing public stories")
    return await list_public_stories()

@router.get("/{story_id}", response_model=StoryOut)
async def get_story_endpoint(story_id: str):
    story = await get_story_by_id(story_id)
    if not story:
        raise HTTPException(status_code=404, detail="Story not found")
    return story

@router.get("/user/{user_id}", response_model=List[StoryOut])
async def list_user_stories(user_id: str):
    return await list_stories_by_user(user_id)


@router.delete("/{story_id}")
async def delete_story_endpoint(story_id: str):
    """
    Delete a story permanently by ID.
    Deletes from MongoDB, Cloudinary video, and cover image.
    """
    # 1. Get the story first to retrieve video and cover URLs
    story = await get_story_by_id(story_id)
    if not story:
        raise HTTPException(status_code=404, detail="Story not found")
    
    # 2. Delete video from Cloudinary if it exists
    video_url = story.get("videoUrl", "")
    if video_url:
        delete_video_from_cloudinary(video_url)
    
    # 3. Delete cover image from Cloudinary if it exists
    cover_url = story.get("coverUrl", "")
    if cover_url:
        delete_image_from_cloudinary(cover_url)
    
    # 4. Delete story from MongoDB
    deleted = await delete_story_by_id(story_id)
    
    if deleted:
        return {
            "message": "Story deleted successfully",
            "story_id": story_id,
            "deleted_video": bool(video_url),
            "deleted_cover": bool(cover_url)
        }
    else:
        raise HTTPException(status_code=500, detail="Failed to delete story")
