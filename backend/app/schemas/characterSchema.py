from typing import Optional
from pydantic import BaseModel, Field

class CharacterCreate(BaseModel):
    characterName: str
    description: Optional[str] = None
    imageURL: Optional[str] = None

class CharacterOut(BaseModel):
    id: Optional[str] = Field(None, alias="id")
    characterName: str
    description: Optional[str] = None
    imageURL: Optional[str] = None
    createdAt: Optional[str] = None
    updatedAt: Optional[str] = None

    model_config = {"from_attributes": True}