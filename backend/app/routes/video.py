from fastapi import APIRouter
from fastapi.responses import FileResponse
import os
import uuid

from app.schemas.story import StoryRequest
from app.services.video_service import generate_story_video
from app.services.videoUpload import upload_video

router = APIRouter(prefix="/video", tags=["Video"])


@router.post("/generate")
def generate_video(request: StoryRequest):
    video_id = str(uuid.uuid4())
    output_dir = os.path.join("output", "videos")
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{video_id}.mp4")

    # Generate video
    generate_story_video(request.story, output_path)

    # Upload to Cloudinary
    video_url = upload_video(output_path, file_name=video_id)
    # (Optional) Delete local file after upload
    if os.path.exists(output_path):
        os.remove(output_path)

    # Return Cloudinary URL instead of file
    return {
        "video_url": video_url
    }
