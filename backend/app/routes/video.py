from fastapi import APIRouter
from fastapi.responses import FileResponse
import os
import uuid

from app.schemas.story import StoryRequest
from app.services.video_service import generate_story_video
from app.services.videoUpload import upload_video, upload_image
import cloudinary

router = APIRouter(prefix="/video", tags=["Video"])

@router.post("/generate")
def generate_video(request: StoryRequest):
    video_id = str(uuid.uuid4())
    output_dir = os.path.join("output", "videos")
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{video_id}.mp4")

    # Generate video (now returns cover image path)
    cover_image_path, title, genre, voice_fallback = generate_story_video(
        request.story,
        output_path,
        language=request.output_language,
        input_language=request.input_language,
    )

    # Upload video to Cloudinary
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
    }
