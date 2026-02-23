from fastapi import APIRouter
from app.schemas.user import UserSignup, UserLogin, UserUpdate
from app.services.auth_service import signup_user, user_login, get_current_user, update_user_profile
from fastapi import APIRouter, Depends
router = APIRouter()

@router.post("/signup")
async def signup(user: UserSignup):
    return await signup_user(user)
@router.post("/login")
async def login(user: UserLogin):
    return await user_login(user)

@router.get("/profile")
async def get_profile(current_user: dict = Depends(get_current_user)):
    return current_user

@router.put("/profile")
async def update_profile(update_data: UserUpdate, current_user: dict = Depends(get_current_user)):
    return await update_user_profile(current_user["id"], update_data)