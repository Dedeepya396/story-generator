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

        if not story:
            raise HTTPException(
                status_code=400,
                detail="Story is required"
            )

        quiz = generate_quiz_from_story(story)

        return quiz

    except HTTPException:
        raise

    except Exception as e:

        print("QUIZ ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )