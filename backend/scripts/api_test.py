import requests

base = "http://127.0.0.1:8000"  # change if your server uses a different port

r = requests.post(f"{base}/users", json={
    "fullName": "API Test",
    "email": "apitest2@example.com",
    "password": "secret123",
    "role": "student"
})

print("POST status:", r.status_code)
print("POST response text:", repr(r.text))

try:
    data = r.json()
    print("POST json:", data)
except Exception as e:
    print("Failed to parse JSON from POST response:", e)

uid = None
try:
    uid = r.json().get("id")
except Exception:
    uid = None

if uid:
    r2 = requests.get(f"{base}/users/{uid}")
    print("GET status:", r2.status_code)
    print("GET response text:", repr(r2.text))
    try:
        print("GET json:", r2.json())
    except Exception as e:
        print("Failed to parse JSON from GET response:", e)