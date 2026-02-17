from typing import Optional
from pydantic import BaseModel, Field

class VideoCreate(BaseModel):
    storyId: str
    userId: str
    videoUrl: str
    status: Optional[str] = "pending"
    displayFlag: Optional[bool] = True

class VideoOut(BaseModel):
    id: Optional[str] = Field(None, alias="id")
    storyId: str
    userId: str
    videoUrl: str
    status: str
    displayFlag: bool
    createdAt: Optional[str] = None
    updatedAt: Optional[str] = None

    model_config = {"from_attributes": True}