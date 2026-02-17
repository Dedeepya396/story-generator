from typing import List
from fastapi import APIRouter, HTTPException
from app.schemas.characterSchema import CharacterCreate, CharacterOut
from app.services.character_service import create_character, get_character_by_id, list_characters

router = APIRouter(prefix="/characters", tags=["characters"])

@router.post("/", response_model=CharacterOut)
async def create_character_endpoint(payload: CharacterCreate):
    created = await create_character(payload)
    return created

@router.get("/{char_id}", response_model=CharacterOut)
async def get_character_endpoint(char_id: str):
    c = await get_character_by_id(char_id)
    if not c:
        raise HTTPException(status_code=404, detail="Character not found")
    return c

@router.get("/", response_model=List[CharacterOut])
async def list_characters_endpoint():
    return await list_characters()