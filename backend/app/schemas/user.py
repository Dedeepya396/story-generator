from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Literal

class SocialLinks(BaseModel):
    facebook: Optional[str] = None
    instagram: Optional[str] = None
    youtube: Optional[str] = None

class Profile(BaseModel):
    bio: Optional[str] = None
    profileImageUrl: Optional[str] = None
    socialLinks: Optional[SocialLinks] = None

class UserSignup(BaseModel):
    fullName: str
    email: EmailStr
    password: str = Field(min_length=6)
    phone: Optional[str] = None
    role: Literal["teacher", "student"]
    profile: Optional[Profile] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    fullName: Optional[str] = None
    password: Optional[str] = Field(None, min_length=6)