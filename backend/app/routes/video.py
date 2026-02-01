import uuid
from fastapi import APIRouter
from fastapi.responses import FileResponse

from app.schemas.story import StoryRequest
from app.services.video_service import generate_story_video

router = APIRouter(prefix="/video", tags=["Video"])

@router.post("/generate")
def generate_video(request: StoryRequest):
    video_id = str(uuid.uuid4())
    output_path = f"output/videos/{video_id}.mp4"

    generate_story_video(request.story, output_path)

    return FileResponse(
        output_path,
        media_type="video/mp4",
        filename="story_video.mp4"
    )
