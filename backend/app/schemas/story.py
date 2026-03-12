from pydantic import BaseModel

class StoryRequest(BaseModel):
    story: str
    output_language: str = "english"    # Renamed from 'language'
    input_language: str = "english"     # ADD THIS FIELD
    gender: str = "female"              # Default to female

    # language: str = "english"
