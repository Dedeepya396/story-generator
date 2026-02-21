# import json
# import os
# from groq import Groq
# from dotenv import load_dotenv
# import os
# import re
# load_dotenv()

# client = Groq(api_key=os.getenv("GROQ_API_KEY"))

# def generate_scenes(story: str, num_scenes: int = 6):
#     prompt = f"""
# Split the following children's story into exactly {num_scenes} scenes.

# Return STRICT JSON:
# [
#   {{
#     "text": "short narration",
#     "prompt": "children's book illustration description"
#   }}
# ]

# Story:
# {story}
# """
#     response = client.chat.completions.create(
#         model="llama-3.1-8b-instant",
#         messages=[{"role": "user", "content": prompt}],
#         temperature=0.7
#     )

#     return json.loads(response.choices[0].message.content)


# ...existing code...
import json
import os
from groq import Groq
from dotenv import load_dotenv
import re
load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def _extract_json_substring(text: str):
    m = re.search(r'(\[.*\]|\{.*\})', text, re.S)
    return m.group(1) if m else text

def _try_fix_and_parse(s: str):
    # try raw parse first
    try:
        return json.loads(s)
    except json.JSONDecodeError:
        # common fixes: single -> double quotes, remove trailing commas
        s2 = s.replace("'", '"')
        s2 = re.sub(r',\s*(?=[}\]])', '', s2)
        return json.loads(s2)

def generate_scenes(story: str, num_scenes: int = 6):
    prompt = f"""
Split the following children's story into exactly {num_scenes} scenes.

Return STRICT JSON:
[
  {{
    "text": "short narration",
    "prompt": "children's book illustration description"
  }}
]

Story:
{story}
"""
    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7
    )

    # content returned by the model
    content = response.choices[0].message.content

    # try strict parse, then fallback to extracting a JSON substring and simple fixes
    try:
        parsed = json.loads(content)
    except Exception:
        json_text = _extract_json_substring(content)
        try:
            parsed = _try_fix_and_parse(json_text)
        except Exception as e:
            raise ValueError(f"Failed to parse model response as JSON. Raw response: {content!r}. Error: {e}")

    # ensure parsed is a list of scene dicts
    if isinstance(parsed, dict) and "scenes" in parsed and isinstance(parsed["scenes"], list):
        scenes = parsed["scenes"]
    elif isinstance(parsed, list):
        scenes = parsed
    else:
        raise ValueError(f"Parsed response is not a list of scenes: {parsed!r}")

    # optional: validate length
    if len(scenes) != num_scenes:
        # you can choose to raise or just log; here we raise to surface inconsistencies
        raise ValueError(f"Model returned {len(scenes)} scenes but expected {num_scenes}. Parsed content: {scenes!r}")

    return scenes
# ...existing code...