import json
import os
from groq import Groq
from dotenv import load_dotenv
import os
import re
load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

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

    return json.loads(response.choices[0].message.content)
