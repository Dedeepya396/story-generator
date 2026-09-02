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
    fullName: Optional[str] = Field(None, alias="name")
    email: str
    password: str = Field(..., min_length=1)
    phone: Optional[str] = None
    role: Optional[str] = "student"
    profile: Optional[Profile] = None

    class Config:
        allow_population_by_field_name = True
        populate_by_name = True


class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    fullName: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=6)