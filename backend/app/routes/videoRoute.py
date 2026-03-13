from typing import List
from fastapi import APIRouter, HTTPException
import os
import uuid
from app.schemas.videoSchema import VideoCreate, VideoOut
from app.schemas.story import StoryRequest
from app.services.videocreation_service import create_video_entry, get_video_by_id, list_videos_by_story
from app.services.video_service import generate_story_video
from app.services.videoUpload import upload_video, upload_image
import cloudinary

router = APIRouter(prefix="/videos", tags=["videos"])

@router.post("/generate")
async def generate_video_endpoint(request: StoryRequest):
    video_id = str(uuid.uuid4())
    output_dir = os.path.join("output", "videos")
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{video_id}.mp4")

    # Generate video (now returns cover image path)
    try:
        cover_image_path, title, genre, voice_fallback = generate_story_video(
            request.story,
            output_path,
            language=request.output_language,
            input_language=request.input_language,
            gender=request.gender,
        )
    except Exception as e:
        print(f"Video generation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Video generation failed: {str(e)}")

    # Upload video to Cloudinary
    try:
        video_url = upload_video(output_path, file_name=video_id)

        # Upload subtitle sidecar (.vtt) if it exists
        vtt_path = os.path.splitext(output_path)[0] + ".vtt"
        subtitle_url = None
        if os.path.exists(vtt_path):
            try:
                resp = cloudinary.uploader.upload(vtt_path, resource_type="raw", public_id=f"subtitles_{video_id}")
                subtitle_url = resp.get("secure_url")
            except Exception as e:
                print(f"Subtitle upload failed: {e}")

        # Upload cover image to Cloudinary
        cover_url = None
        if cover_image_path and os.path.exists(cover_image_path):
            cover_url = upload_image(cover_image_path, file_name=f"cover_{video_id}")
            # (Optional) Delete local cover image after upload
            try:
                os.remove(cover_image_path)
            except Exception:
                pass

        # (Optional) Delete local video and vtt file after upload
        try:
            if os.path.exists(output_path):
                os.remove(output_path)
            if subtitle_url and os.path.exists(vtt_path):
                try:
                    os.remove(vtt_path)
                except Exception:
                    pass
        except Exception:
            pass

        # Return Cloudinary URLs
        return {
            "video_url": video_url,
            "video_path": video_url,
            "subtitle_url": subtitle_url,
            "cover_url": cover_url,
            "cover_image": cover_url,
            "title": title,
            "genre": genre,
            "input_language": request.input_language,
            "output_language": request.output_language,
            "voice_fallback": voice_fallback,
        }
    except Exception:
        pass
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