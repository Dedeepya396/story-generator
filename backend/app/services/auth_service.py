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

import hashlib
import os
from fastapi import HTTPException
from datetime import datetime
from app.schemas.user import UserLogin
from app.db import users_collection

import jwt
from datetime import datetime, timedelta

SECRET_KEY = "your_super_secret_key_here"  # move to .env in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60  # 1 hour token

def create_access_token(data: dict, expires_delta: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=expires_delta)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_password(plain_password: str, salt_hex: str, hash_hex: str) -> bool:
    salt = bytes.fromhex(salt_hex)
    hash_bytes = bytes.fromhex(hash_hex)
    new_hash = hashlib.pbkdf2_hmac("sha256", plain_password.encode("utf-8"), salt, 100_000)
    return new_hash == hash_bytes

async def user_login(user: UserLogin) -> dict:
    existing_user = await users_collection.find_one({"email": user.email})
    if existing_user is None:
        raise HTTPException(status_code=400, detail="New User? Signup!")

    salt_hex = existing_user['password_salt']
    hash_hex = existing_user['password_hash']

    if not verify_password(user.password, salt_hex, hash_hex):
        raise HTTPException(status_code=400, detail="Incorrect Password!")

    # Generate JWT token
    token_data = {"user_id": str(existing_user["_id"]), "email": existing_user["email"]}
    access_token = create_access_token(token_data)

    # Optionally, you can store the token in the DB if you want session tracking
    # await users_collection.update_one({"_id": existing_user["_id"]}, {"$set": {"jwt_token": access_token}})

    return {
        "message": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user":{
            "id": str(existing_user["_id"]),
            "email": existing_user.get("email"),
            "name": existing_user.get("fullName")
        }
    }
