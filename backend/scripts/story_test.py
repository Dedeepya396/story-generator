import os
import requests
import sys
from pprint import pprint

BASE = "http://127.0.0.1:8000"

def safe_json(r):
    try:
        return r.json()
    except Exception:
        return r.text

def create_user():
    payload = {
        "fullName": "Story Test User",
        "email": "storytest@example.com",
        "password": "testpass123",
        "role": "student"
    }
    r = requests.post(f"{BASE}/users", json=payload, timeout=15)
    print("CREATE USER:", r.status_code)
    pprint(safe_json(r))
    if r.status_code == 200 or r.status_code == 201:
        return safe_json(r).get("id")
    return None

def create_story(user_id):
    payload = {
        "userId": user_id,
        "title": "Automated Test Story",
        "description": "This is a test story created by automated script.",
        "language": "en",
        "genre": "test"
    }
    r = requests.post(f"{BASE}/stories", json=payload, timeout=15)
    print("CREATE STORY:", r.status_code)
    pprint(safe_json(r))
    if r.status_code in (200, 201):
        return safe_json(r).get("id")
    return None

def get_story(story_id):
    r = requests.get(f"{BASE}/stories/{story_id}", timeout=10)
    print(f"GET STORY {story_id}:", r.status_code)
    pprint(safe_json(r))

def list_stories_by_user(user_id):
    r = requests.get(f"{BASE}/stories/user/{user_id}", timeout=10)
    print(f"LIST STORIES FOR USER {user_id}:", r.status_code)
    pprint(safe_json(r))

def main():
    # 1) create user (or set EXISTING_USER env var to skip)
    # user_id = os.getenv("EXISTING_USER_ID")
    user_id = "699459c165dba441ba2f00a2"
    if not user_id:
        print("No EXISTING_USER_ID provided — creating temporary user")
        user_id = create_user()
        if not user_id:
            print("Failed to create user. Exiting.", file=sys.stderr)
            sys.exit(1)
    else:
        print("Using EXISTING_USER_ID:", user_id)

    # 2) create story
    story_id = create_story(user_id)
    if not story_id:
        print("Story creation failed. Exiting.", file=sys.stderr)
        sys.exit(1)

    # 3) get story by id
    get_story(story_id)

    # 4) list stories by user
    list_stories_by_user(user_id)

if __name__ == "__main__":
    main()