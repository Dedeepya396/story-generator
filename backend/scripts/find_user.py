from dotenv import load_dotenv
import os
from pymongo import MongoClient
from bson import ObjectId

load_dotenv()
uri = os.getenv("MONGO_URI")
db_name = os.getenv("MONGO_DB", "story_generator")

client = MongoClient(uri)
db = client[db_name]

doc_id = "699459c165dba441ba2f00a2"  # your inserted id
doc = db["users"].find_one({"_id": ObjectId(doc_id)})
print(doc)

# list first 10 documents
for d in db["users"].find().limit(10):
    print(d)