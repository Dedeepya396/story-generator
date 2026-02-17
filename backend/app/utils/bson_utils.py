from typing import Any
from bson import ObjectId

def stringify_object_ids(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {k: stringify_object_ids(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [stringify_object_ids(v) for v in obj]
    if isinstance(obj, ObjectId):
        return str(obj)
    return obj