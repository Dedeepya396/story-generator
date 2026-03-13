import os
from mistralai import Mistral

api_key = os.getenv("MISTRAL_API_KEY")
client = Mistral(api_key=api_key)


async def generate_story(prompt: str = None, genre: str = None):

    # Default prompt
    if prompt:
        user_prompt = prompt
    else:
        user_prompt = f"Generate a creative {genre or 'fantasy'} story suitable for a visual story generator."

    # Default token limit
    max_tokens = 400

    # Adjust tokens based on prompt hints
    if prompt:
        p = prompt.lower()

        if "very short" in p or "2 line" in p or "two line" in p:
            max_tokens = 50
        elif "short" in p:
            max_tokens = 80
        elif "medium" in p:
            max_tokens = 200
        elif "long" in p:
            max_tokens = 300

    chat_response = client.chat.complete(
        model="mistral-small-latest",
        messages=[
            {
                "role": "system",
                "content": (
                    "You are a creative storyteller. "
                    "Always follow the user's instructions exactly. "
                    "If the user specifies story length or format, follow it strictly. "
                    "Write stories that are vivid and suitable for visual scene generation."
                ),
            },
            {
                "role": "user",
                "content": user_prompt,
            },
        ],
        temperature=0.9,
        max_tokens=max_tokens,
    )

    story = chat_response.choices[0].message.content
    return story