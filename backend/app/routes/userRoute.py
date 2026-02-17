from fastapi import APIRouter, HTTPException
from app.schemas.user import UserCreate, UserOut
from app.services.user_service import create_user, get_user_by_id

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserOut)
async def create_user_endpoint(payload: UserCreate):
    created = await create_user(payload)
    return created

@router.get("/{user_id}", response_model=UserOut)
async def get_user_endpoint(user_id: str):
    user = await get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user