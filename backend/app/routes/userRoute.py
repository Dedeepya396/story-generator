from fastapi import APIRouter
from app.schemas.user import UserSignup, UserLogin
from app.services.auth_service import signup_user, user_login
router = APIRouter()

@router.post("/signup")
async def signup(user: UserSignup):
    return await signup_user(user)
@router.post("/login")
async def login(user: UserLogin):
    return await user_login(user)