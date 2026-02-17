from typing import Optional, Dict
from pydantic import BaseModel, Field

class SocialLinks(BaseModel):
    facebook: Optional[str] = None
    instagram: Optional[str] = None
    youtube: Optional[str] = None

class UserProfile(BaseModel):
    bio: Optional[str] = None
    profileImageUrl: Optional[str] = None
    socialLinks: Optional[SocialLinks] = None

class UserStats(BaseModel):
    storiesCreated: int = 0
    mostViewedStoryId: Optional[str] = None  # store ObjectId as str
    recentStoryId: Optional[str] = None      # store ObjectId as str

# class UserCreate(BaseModel):
#     fullName: str
#     email: str
#     password: str
#     phone: Optional[str] = None
#     role: str = Field(..., regex="^(teacher|student)$")
#     profile: Optional[UserProfile] = None

# ...existing code...
from typing import Literal
class UserCreate(BaseModel):
    fullName: str
    email: str
    password: str
    phone: Optional[str] = None
    role: Literal["teacher", "student"]
    profile: Optional[UserProfile] = None
# ...existing code...

class UserOut(BaseModel):
    id: Optional[str] = Field(None, alias="id")  # will map Mongo _id -> id (string)
    fullName: str
    email: str
    phone: Optional[str] = None
    role: str
    profile: Optional[UserProfile] = None
    stats: Optional[UserStats] = None
    createdAt: Optional[str] = None
    updatedAt: Optional[str] = None

    model_config = {"from_attributes": True}