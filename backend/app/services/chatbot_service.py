import os
from mistralai import Mistral

api_key = os.getenv("MISTRAL_API_KEY")

client = Mistral(api_key=api_key)


async def generate_story(prompt: str = None, genre: str = None):

    if prompt:
        user_prompt = prompt
    else:
        user_prompt = f"Generate a short creative {genre or 'fantasy'} story suitable for a visual story generator."

    chat_response = client.chat.complete(
        model="mistral-small-latest",
        messages=[
            {
                "role": "system",
                "content": "You are a creative storyteller. Write short visual stories suitable for scene generation."
            },
            {
                "role": "user",
                "content": user_prompt
            }
        ],
        temperature=0.9,
        max_tokens=500
    )

    story = chat_response.choices[0].message.content

    return story