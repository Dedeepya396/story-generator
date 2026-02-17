import os
import sys
import requests
from pprint import pprint

BASE = os.getenv("API_BASE", "http://127.0.0.1:8000")
TIMEOUT = 15

def safe_json(r):
    try:
        return r.json()
    except Exception:
        return r.text

def create_user():
    payload = {
        "fullName": "Video Test User",
        "email": "videotest@example.com",
        "password": "testpass123",
        "role": "student"
    }
    r = requests.post(f"{BASE}/users", json=payload, timeout=TIMEOUT)
    print("CREATE USER:", r.status_code)
    pprint(safe_json(r))
    if r.status_code in (200,201):
        return safe_json(r).get("id")
    return None

def create_story(user_id):
    payload = {
        "userId": user_id,
        "title": "Video Test Story",
        "description": "Story for video tests",
        "language": "en",
        "genre": "test"
    }
    r = requests.post(f"{BASE}/stories", json=payload, timeout=TIMEOUT)
    print("CREATE STORY:", r.status_code)
    pprint(safe_json(r))
    if r.status_code in (200,201):
        return safe_json(r).get("id")
    return None

def create_video(story_id, user_id):
    payload = {
        "storyId": story_id,
        "userId": user_id,
        "videoUrl": "https://example.com/videos/test.mp4",
        "status": "completed",
        "displayFlag": True
    }
    r = requests.post(f"{BASE}/videos", json=payload, timeout=TIMEOUT)
    print("CREATE VIDEO:", r.status_code)
    pprint(safe_json(r))
    if r.status_code in (200,201):
        return safe_json(r).get("id")
    return None

def get_video(video_id):
    r = requests.get(f"{BASE}/videos/{video_id}", timeout=TIMEOUT)
    print("GET VIDEO:", r.status_code)
    pprint(safe_json(r))

def list_videos_for_story(story_id):
    r = requests.get(f"{BASE}/videos/story/{story_id}", timeout=TIMEOUT)
    print("LIST VIDEOS FOR STORY:", r.status_code)
    pprint(safe_json(r))

def main():
    user_id = os.getenv("EXISTING_USER_ID")
    if not user_id:
        user_id = create_user()
        if not user_id:
            print("Failed to obtain user id", file=sys.stderr); sys.exit(1)

    story_id = os.getenv("EXISTING_STORY_ID")
    if not story_id:
        story_id = create_story(user_id)
        if not story_id:
            print("Failed to obtain story id", file=sys.stderr); sys.exit(1)

    video_id = create_video(story_id, user_id)
    if not video_id:
        print("Video creation failed", file=sys.stderr); sys.exit(1)

    get_video(video_id)
    list_videos_for_story(story_id)

if __name__ == "__main__":
    main()