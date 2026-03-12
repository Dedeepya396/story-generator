from pydantic import BaseModel
from typing import Optional

class StoryRequest(BaseModel):
    prompt: Optional[str] = None
    genre: Optional[str] = None


class StoryResponse(BaseModel):
    story: str