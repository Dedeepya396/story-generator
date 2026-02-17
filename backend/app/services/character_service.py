from typing import Optional, List
from bson import ObjectId
import datetime

from app.db import db
from app.utils.bson_utils import stringify_object_ids
from app.schemas.characterSchema import CharacterCreate

async def create_character(payload: CharacterCreate) -> dict:
    doc = payload.model_dump()
    now = datetime.datetime.utcnow()
    doc["createdAt"] = now
    doc["updatedAt"] = now
    res = await db["characters"].insert_one(doc)
    doc["_id"] = res.inserted_id
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out

async def get_character_by_id(char_id: str) -> Optional[dict]:
    try:
        oid = ObjectId(char_id)
    except Exception:
        return None
    doc = await db["characters"].find_one({"_id": oid})
    if not doc:
        return None
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out

async def list_characters() -> List[dict]:
    docs = db["characters"].find()
    results = []
    async for d in docs:
        out = stringify_object_ids(d)
        out["id"] = out.pop("_id")
        for k in ("createdAt", "updatedAt"):
            v = out.get(k)
            if isinstance(v, datetime.datetime):
                out[k] = v.isoformat()
        results.append(out)
    return results