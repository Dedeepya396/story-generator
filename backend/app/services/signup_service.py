# app/services/signup_service.py
import hashlib
import os
from fastapi import HTTPException
from datetime import datetime
from app.schemas.user import UserSignup
from app.db import users_collection

def hash_password(password: str, salt: bytes = None) -> (str, str):
    """
    Hash a password using SHA-256 with a salt.
    Returns tuple: (salt_hex, hash_hex)
    """
    if salt is None:
        salt = os.urandom(16)  # 16 bytes random salt

    # Encode password and combine with salt
    pw_bytes = password.encode("utf-8")
    hash_bytes = hashlib.pbkdf2_hmac("sha256", pw_bytes, salt, 100_000)  # 100k iterations

    # Return as hex strings for storage
    return salt.hex(), hash_bytes.hex()


def verify_password(plain_password: str, salt_hex: str, hash_hex: str) -> bool:
    """
    Verify a password against stored salt + hash
    """
    salt = bytes.fromhex(salt_hex)
    hash_bytes = bytes.fromhex(hash_hex)
    new_hash = hashlib.pbkdf2_hmac("sha256", plain_password.encode("utf-8"), salt, 100_000)
    return new_hash == hash_bytes


async def signup_user(user: UserSignup) -> dict:
    """
    Create a new user in MongoDB
    """
    # Check if email exists
    existing_user = await users_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash password
    salt_hex, hash_hex = hash_password(user.password)

    # Prepare MongoDB doc
    user_dict = user.dict()
    user_dict["password_salt"] = salt_hex
    user_dict["password_hash"] = hash_hex
    user_dict.pop("password")  # remove plain password
    user_dict["createdAt"] = datetime.utcnow()

    # Insert into DB
    result = await users_collection.insert_one(user_dict)

    return {"message": "User created successfully", "user_id": str(result.inserted_id)}
