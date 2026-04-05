from pydantic import BaseModel
from typing import List, Dict, Optional

class StoryRequest(BaseModel):
    story: str
    output_language: str = "english"    # Renamed from 'language'
    input_language: str = "english"     # ADD THIS FIELD
    gender: str = "female"              # Default to female

class RevoiceRequest(BaseModel):
    story: str
    scenes: List[Dict]
    image_urls: List[str]
    target_language: str = "hindi"
    gender: str = "female"
