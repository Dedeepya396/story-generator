from typing import Optional
from pydantic import BaseModel, Field

class StoryCreate(BaseModel):
    userId: str
    title: str
    description: Optional[str] = None
    language: Optional[str] = None
    genre: Optional[str] = None
    videoUrl: Optional[str] = None
    displayFlag: Optional[bool] = True

class StoryOut(BaseModel):
    id: Optional[str] = Field(None, alias="id")
    userId: str
    title: str
    description: Optional[str] = None
    language: Optional[str] = None
    genre: Optional[str] = None
    createdAt: Optional[str] = None
    updatedAt: Optional[str] = None

    model_config = {"from_attributes": True}