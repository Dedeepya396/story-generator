from fastapi import APIRouter, Request, HTTPException

from app.services.quiz_service import generate_quiz_from_story


router = APIRouter(
    prefix="/quiz",
    tags=["Quiz"]
)


@router.post("/generate")
async def generate_quiz(request: Request):

    try:

        data = await request.json()

        story = data.get("story")
        language = data.get("language") or data.get("output_language") or "english"
        video_duration = data.get("video_duration") or data.get("duration")

        if not story:
            raise HTTPException(
                status_code=400,
                detail="Story is required"
            )

        quiz = generate_quiz_from_story(story, language=language, video_duration=video_duration)

        return quiz

    except HTTPException:
        raise

    except Exception as e:

        print("QUIZ ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )