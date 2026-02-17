import datetime
from typing import Optional
from bson import ObjectId

from app.db import db
from app.utils.bson_utils import stringify_object_ids
from app.schemas.user import UserCreate

# ...existing code...
import datetime
# ...existing code...

async def create_user(payload: UserCreate) -> dict:
    doc = payload.model_dump()
    now = datetime.datetime.utcnow()
    doc["createdAt"] = now
    doc["updatedAt"] = now
    res = await db["users"].insert_one(doc)
    doc["_id"] = res.inserted_id

    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")

    # convert datetime fields to ISO strings for response
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()

    return out
# ...existing code...

async def get_user_by_id(user_id: str) -> Optional[dict]:
    try:
        oid = ObjectId(user_id)
    except Exception:
        return None
    doc = await db["users"].find_one({"_id": oid})
    if not doc:
        return None
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")

    # convert datetime fields to ISO strings for response
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()

    return out
# ...existing code...