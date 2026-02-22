from fastapi import APIRouter
from fastapi.responses import FileResponse
import os
import uuid

from app.schemas.story import StoryRequest
from app.services.video_service import generate_story_video
from app.services.videoUpload import upload_video, upload_image

router = APIRouter(prefix="/video", tags=["Video"])

@router.post("/generate")
def generate_video(request: StoryRequest):
    video_id = str(uuid.uuid4())
    output_dir = os.path.join("output", "videos")
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{video_id}.mp4")

    # Generate video (now returns cover image path)
    cover_image_path = generate_story_video(request.story, output_path)

    # Upload video to Cloudinary
    video_url = upload_video(output_path, file_name=video_id)
    
    # Upload cover image to Cloudinary
    cover_url = None
    if cover_image_path and os.path.exists(cover_image_path):
        cover_url = upload_image(cover_image_path, file_name=f"cover_{video_id}")
        # (Optional) Delete local cover image after upload
        os.remove(cover_image_path)

    # (Optional) Delete local video file after upload
    if os.path.exists(output_path):
        os.remove(output_path)

    # Return Cloudinary URLs
    return {
        "video_url": video_url,
        "cover_url": cover_url
    }
