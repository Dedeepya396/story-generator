import os
import json

from dotenv import load_dotenv
from groq import Groq


load_dotenv()

api_key = os.getenv("GROQ_API_KEY")

if not api_key:
    raise Exception("GROQ_API_KEY not found")

client = Groq(api_key=api_key)


def generate_quiz_from_story(story: str, language: str = "english"):

    prompt = f"""
You are an educational quiz generator for children.

Read the story below and create exactly 5 diverse questions testing comprehension.
Include a variety of question types across the 5 questions:
- "mcq" (Multiple Choice Question): 4 options, 1 correct option index (0, 1, 2, or 3).
- "true_false" (True or False Question): 2 options representing True and False in {language}, 1 correct option index (0 or 1).
- "fill_blank" (Fill in the Blank Question): Sentence text containing a blank "_____", 4 word options to fill the blank, 1 correct option index (0, 1, 2, or 3).

Language requirement:
- The entire quiz (all question texts, statements, and option texts) MUST be written in the {language} language.
- If {language} is not English (such as Hindi, Telugu, Tamil, Malayalam, Kannada, Bengali, Gujarati, Marathi, Punjabi, Odia, Assamese, etc.), generate/translate all questions and options into {language}.

Rules:
- Create exactly 5 questions.
- Include a mix of "mcq", "true_false", and "fill_blank" question types.
- Questions must be based ONLY on the story.
- Do not use outside knowledge.
- Use simple, clear language suitable for children.

Return ONLY valid JSON using this format:

{{
    "questions": [
        {{
            "type": "mcq",
            "question": "Question text in {language}",
            "options": [
                "Option 1 in {language}",
                "Option 2 in {language}",
                "Option 3 in {language}",
                "Option 4 in {language}"
            ],
            "answer": 0
        }},
        {{
            "type": "true_false",
            "question": "Statement text in {language}",
            "options": [
                "True text in {language}",
                "False text in {language}"
            ],
            "answer": 0
        }},
        {{
            "type": "fill_blank",
            "question": "Sentence with _____ in {language}",
            "options": [
                "Word 1 in {language}",
                "Word 2 in {language}",
                "Word 3 in {language}",
                "Word 4 in {language}"
            ],
            "answer": 0
        }}
    ]
}}

The answer field represents the 0-based index of the correct option.

STORY:

{story}
"""

    response = client.chat.completions.create(
        model="openai/gpt-oss-20b",

        messages=[
            {
                "role": "system",
                "content": f"You generate educational quizzes for children with diverse question types in {language} language."
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

        q_type = question.get("type", "mcq")
        if q_type not in ["mcq", "true_false", "fill_blank"]:
            question["type"] = "mcq"

        options = question["options"]
        if not isinstance(options, list):
            raise Exception("Options must be a list")

        if q_type == "true_false":
            if len(options) < 2:
                raise Exception("True/False question must have at least 2 options")
        else:
            if len(options) != 4:
                raise Exception("MCQ/Fill-in-the-blank question must have 4 options")

        if "answer" not in question:
            raise Exception("Answer missing")

        try:
            ans = int(question["answer"])
            if ans < 0 or ans >= len(options):
                raise Exception("Answer index out of range")
            question["answer"] = ans
        except (ValueError, TypeError):
            raise Exception("Invalid answer index format")

    return quiz