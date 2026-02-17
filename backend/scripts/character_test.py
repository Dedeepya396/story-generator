import os
import requests
from pprint import pprint

BASE = os.getenv("API_BASE", "http://127.0.0.1:8000")
TIMEOUT = 15

def safe_json(r):
    try:
        return r.json()
    except Exception:
        return r.text

def create_character():
    payload = {
        "characterName": "Rusty",
        "description": "Friendly test character",
        "imageURL": "https://example.com/images/rusty.png"
    }
    r = requests.post(f"{BASE}/characters", json=payload, timeout=TIMEOUT)
    print("CREATE CHARACTER:", r.status_code)
    pprint(safe_json(r))
    if r.status_code in (200,201):
        return safe_json(r).get("id")
    return None

def get_character(char_id):
    r = requests.get(f"{BASE}/characters/{char_id}", timeout=TIMEOUT)
    print("GET CHARACTER:", r.status_code)
    pprint(safe_json(r))

def list_characters():
    r = requests.get(f"{BASE}/characters", timeout=TIMEOUT)
    print("LIST CHARACTERS:", r.status_code)
    pprint(safe_json(r))

def main():
    char_id = create_character()
    if char_id:
        get_character(char_id)
    list_characters()

if __name__ == "__main__":
    main()