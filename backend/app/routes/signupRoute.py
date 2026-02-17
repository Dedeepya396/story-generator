from fastapi import APIRouter
from app.schemas.user import UserSignup
from app.services.signup_service import signup_user

router = APIRouter()

@router.post("/signup")
async def signup(user: UserSignup):
    return await signup_user(user)
