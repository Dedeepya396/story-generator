from pydantic import BaseModel

class StoryRequest(BaseModel):
    story: str
