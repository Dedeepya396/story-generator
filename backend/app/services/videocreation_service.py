from typing import Optional, List
from bson import ObjectId
import datetime

from app.db import db
from app.utils.bson_utils import stringify_object_ids
from app.schemas.videoSchema import VideoCreate

async def create_video_entry(payload: VideoCreate) -> dict:
    doc = payload.model_dump()
    now = datetime.datetime.utcnow()
    doc["createdAt"] = now
    doc["updatedAt"] = now
    res = await db["videos"].insert_one(doc)
    doc["_id"] = res.inserted_id
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out

async def get_video_by_id(video_id: str) -> Optional[dict]:
    try:
        oid = ObjectId(video_id)
    except Exception:
        return None
    doc = await db["videos"].find_one({"_id": oid})
    if not doc:
        return None
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out

async def list_videos_by_story(story_id: str) -> List[dict]:
    docs = db["videos"].find({"storyId": ObjectId(story_id)})
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