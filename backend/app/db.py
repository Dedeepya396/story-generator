import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

load_dotenv()  # loads .env in backend/ if present

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB = os.getenv("MONGO_DB", "story_generator")

# Async Motor client and db object for import elsewhere
client = AsyncIOMotorClient(MONGO_URI)
db = client[MONGO_DB]