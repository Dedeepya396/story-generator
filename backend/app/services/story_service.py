from typing import Optional, List
from bson import ObjectId
import datetime

from app.db import db
from app.utils.bson_utils import stringify_object_ids
from app.schemas.storySchema import StoryCreate

async def create_story(payload: StoryCreate) -> dict:
    doc = payload.model_dump()
    now = datetime.datetime.utcnow()
    doc["createdAt"] = now
    doc["updatedAt"] = now
    res = await db["stories"].insert_one(doc)
    doc["_id"] = res.inserted_id
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    # convert datetimes to ISO strings
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out

async def get_story_by_id(story_id: str) -> Optional[dict]:
    try:
        oid = ObjectId(story_id)
    except Exception:
        return None
    doc = await db["stories"].find_one({"_id": oid})
    if not doc:
        return None
    out = stringify_object_ids(doc)
    out["id"] = out.pop("_id")
    for k in ("createdAt", "updatedAt"):
        v = out.get(k)
        if isinstance(v, datetime.datetime):
            out[k] = v.isoformat()
    return out


async def list_stories_by_user(user_id: str) -> List[dict]:
    # try ObjectId query first
    query = {}
    if ObjectId.is_valid(user_id):
        query = {"$or": [{"userId": ObjectId(user_id)}, {"userId": user_id}]}
    else:
        query = {"userId": user_id}

    docs = db["stories"].find(query)
    results = []
    async for d in docs:
        out = stringify_object_ids(d)
        out["id"] = out.pop("_id")
        for k in ("createdAt", "updatedAt"):
            v = out.get(k)
            if isinstance(v, datetime.datetime):
                out[k] = v.isoformat()
        results.append(out)
    print(f"Found {len(results)} stories for userId={user_id}")
    print(results)
    return results


async def list_public_stories() -> List[dict]:
    """
    Return all stories with displayFlag == True, sorted by createdAt desc.
    """
    cursor = db["stories"].find({"displayFlag": True}).sort("createdAt", -1)
    results: List[dict] = []
    async for d in cursor:
        out = stringify_object_ids(d)
        out["id"] = out.pop("_id")
        for k in ("createdAt", "updatedAt"):
            v = out.get(k)
            if isinstance(v, datetime.datetime):
                out[k] = v.isoformat()
        results.append(out)
    print(f"Found {len(results)} public stories")
    return results


async def delete_story_by_id(story_id: str) -> bool:
    """
    Delete a story by ID from MongoDB.
    Returns True if successful, False otherwise.
    """
    try:
        oid = ObjectId(story_id)
    except Exception:
        print(f"Invalid story ID format: {story_id}")
        return False
    
    result = await db["stories"].delete_one({"_id": oid})
    
    if result.deleted_count > 0:
        print(f"✅ Story {story_id} deleted from database")
        return True
    else:
        print(f"❌ Story {story_id} not found in database")
        return False


# async def list_stories_by_user(user_id: str) -> List[dict]:
#     docs = db["stories"].find({"userId": ObjectId(user_id)})
#     results = []
#     async for d in docs:
#         out = stringify_object_ids(d)
#         out["id"] = out.pop("_id")
#         for k in ("createdAt", "updatedAt"):
#             v = out.get(k)
#             if isinstance(v, datetime.datetime):
#                 out[k] = v.isoformat()
#         results.append(out)
#     return results