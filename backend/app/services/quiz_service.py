import os
import json

from dotenv import load_dotenv
from groq import Groq


load_dotenv()

api_key = os.getenv("GROQ_API_KEY")

if not api_key:
    raise Exception("GROQ_API_KEY not found")

client = Groq(api_key=api_key)


def generate_quiz_from_story(story: str):

    prompt = f"""
You are an educational quiz generator for children.

Read the story below and create exactly 5
multiple-choice questions.

Rules:
- Create exactly 5 questions.
- Each question must have exactly 4 options.
- Only ONE option must be correct.
- Questions must be based ONLY on the story.
- Do not use outside knowledge.
- Use simple language suitable for children.
- Do not create trick questions.
- Questions should cover different parts of the story.

Return ONLY valid JSON.

Use exactly this format:

{{
    "questions": [
        {{
            "question": "Question text",
            "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
            ],
            "answer": 0
        }}
    ]
}}

The answer field represents the index of the correct option:

0 = Option 1
1 = Option 2
2 = Option 3
3 = Option 4

STORY:

{story}
"""

    response = client.chat.completions.create(
        model="openai/gpt-oss-20b",

        messages=[
            {
                "role": "system",
                "content": "You generate educational quizzes."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],

        temperature=0.3,

        response_format={
            "type": "json_object"
        }
    )

    content = response.choices[0].message.content

    quiz = json.loads(content)

    # Validate
    if "questions" not in quiz:
        raise Exception("Invalid response from Groq")

    if len(quiz["questions"]) != 5:
        raise Exception(
            "Groq did not generate exactly 5 questions"
        )

    for question in quiz["questions"]:

        if "question" not in question:
            raise Exception("Question text missing")

        if "options" not in question:
            raise Exception("Options missing")

        if len(question["options"]) != 4:
            raise Exception(
                "Question does not have 4 options"
            )

        if "answer" not in question:
            raise Exception("Answer missing")

        if question["answer"] not in [0, 1, 2, 3]:
            raise Exception("Invalid answer index")

    return quiz