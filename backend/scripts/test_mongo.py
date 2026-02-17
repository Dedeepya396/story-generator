import os
import datetime
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()  # loads backend/.env

MONGO_URI = os.getenv("MONGO_URI")
MONGO_DB = os.getenv("MONGO_DB", "story_generator")

client = MongoClient(MONGO_URI)
db = client[MONGO_DB]

doc = {
    "fullName": "Test User",
    "email": "test@example.com",
    "passwordHash": "testhash",     # replace with hashed password in real usage
    "phone": "1234567890",
    "role": "student",
    "profile": {
        "bio": "Test account",
        "profileImageUrl": "",
        "socialLinks": {}
    },
    "stats": {
        "storiesCreated": 0,
        "mostViewedStoryId": None,
        "recentStoryId": None
    },
    "createdAt": datetime.datetime.utcnow(),
    "updatedAt": datetime.datetime.utcnow()
}

res = db["users"].insert_one(doc)
print("Inserted id:", res.inserted_id)
print("users collection count now:", db["users"].count_documents({}))