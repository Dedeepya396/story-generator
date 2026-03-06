import json
import os
import time
import shutil
from typing import List, Dict

from dotenv import load_dotenv
from gtts import gTTS
from groq import Groq
from huggingface_hub import InferenceClient
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips
from mistralai import Mistral


# Import AI4Bharat service
from app.services.ai4bharat_service import generate_multilingual_audio


client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])
load_dotenv()

HF_TOKEN = os.getenv("HF_TOKEN")
# GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# if not GROQ_API_KEY:
    # raise RuntimeError("GROQ_API_KEY is not set.")
if not HF_TOKEN:
    raise RuntimeError("HF_TOKEN is not set.")

# groq_client = Groq(api_key=GROQ_API_KEY)
hf_client = InferenceClient(token=HF_TOKEN)


# def _generate_scenes_from_story(story_text: str, num_scenes: int = 6) -> List[Dict]:
#     """
#     Ask Groq LLM to split story into JSON scenes.
#     """
#     prompt = f"""
#     Split the following children's story into exactly {num_scenes} scenes.
    
#     Return STRICT JSON format only:
#     [
#       {{
#         "text": "short narration",
#         "prompt": "children's book illustration description, detailed, colorful, 4k"
#       }}
#     ]
    
#     Story:
#     {story_text}
#     """

#     response = groq_client.chat.completions.create(
#         model="llama-3.1-8b-instant",
#         messages=[{"role": "user", "content": prompt}],
#         temperature=0.7,
#     )

#     raw_content = response.choices[0].message.content or ""

#     start = raw_content.find("[")
#     end = raw_content.rfind("]") + 1
#     if start == -1 or end == 0:
#         raise ValueError(f"Could not find JSON in model response: {raw_content!r}")

#     json_text = raw_content[start:end]
#     return json.loads(json_text)

def _generate_scenes_from_story(story_text: str, num_scenes: int = 6) -> List[Dict]:
    """
    Ask Mistral LLM to split story into JSON scenes.
    """

    prompt = f"""
    Split the following children's story into exactly {num_scenes} scenes.

    Return STRICT JSON format only:
    [
      {{
        "text": "short narration",
        "prompt": "children's book illustration description, detailed, colorful, 4k"
      }}
    ]

    Story:
    {story_text}
    """

    response = client.chat.complete(
        model="mistral-large-latest",  # you can also use mistral-small-latest
        messages=[
            {"role": "user", "content": prompt}
        ],
        temperature=0.7,
    )

    raw_content = response.choices[0].message.content or ""

    start = raw_content.find("[")
    end = raw_content.rfind("]") + 1
    if start == -1 or end == 0:
        raise ValueError(f"Could not find JSON in model response: {raw_content!r}")

    json_text = raw_content[start:end]
    return json.loads(json_text)
def generate_story_video(story: str, output_path: str , language: str = "english") -> str:
    """
    Main entry used by the FastAPI route.
    Generates a video file at `output_path` from the given story text.
    Returns the path to the first image (cover image).
    """
    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    cover_image_path = ""

    scenes = _generate_scenes_from_story(story)
    if not scenes:
        raise ValueError("No scenes generated from story.")

    clips = []
    temp_files: List[str] = []

    try:
        for i, scene in enumerate(scenes):
            # --- A. Audio with gTTS ---
            audio_path = os.path.join("output", "videos", f"tmp_audio_{i}.mp3")
            os.makedirs(os.path.dirname(audio_path), exist_ok=True)
            
            # Check if we need translation + Indic TTS
            if language.lower() != "english":
                # Use AI4Bharat pipeline (Translation + VITS TTS)
                print(f"Scene {i}: Translating to {language}...")
                translated_text, indic_audio_path = generate_multilingual_audio(
                    english_text=scene["text"],
                    target_language=language,
                    output_path=audio_path
                )
                print(f"  Original: {scene['text']}")
                print(f"  Translated: {translated_text}")
                temp_files.append(indic_audio_path)
                audio_path = indic_audio_path  # Use the WAV file
            else:
                # Use gTTS for English
                print(f"Scene {i}: Generating English audio...")
                mp3_path = audio_path.replace('.wav', '.mp3')
                tts = gTTS(scene["text"])
                tts.save(mp3_path)
                temp_files.append(mp3_path)
                audio_path = mp3_path

            audio_clip = AudioFileClip(audio_path)

            # tts = gTTS(scene["text"])
            # tts.save(audio_path)
            # temp_files.append(audio_path)

            # audio_clip = AudioFileClip(audio_path)

            # --- B. Image with Hugging Face ---
            img_path = os.path.join("output", "videos", f"tmp_image_{i}.jpg")
            temp_files.append(img_path)

            try:
                print(f"Generating image for scene {i}...")
                image = hf_client.text_to_image(
                    scene["prompt"],
                    model="black-forest-labs/FLUX.1-schnell",
                )
                image.save(img_path)
            except Exception as e:
                print(f"Error generating image for scene {i}: {e}")
                # Fallback: black image so pipeline doesn’t break
                from PIL import Image

                os.makedirs(os.path.dirname(img_path), exist_ok=True)
                img = Image.new("RGB", (1024, 1024), color="black")
                img.save(img_path)
            
            if i == 0:
                # Save the first image as cover image
                cover_dir = os.path.join("output", "covers")
                os.makedirs(cover_dir, exist_ok=True)
                cover_image_path = os.path.join(cover_dir, f"cover_{int(time.time())}.jpg")
                shutil.copy(img_path, cover_image_path)

            # Rate limit safety - always wait 10s between calls
            time.sleep(10)

            # --- C. Video clip per scene ---
            video_clip = ImageClip(img_path).set_duration(audio_clip.duration)
            video_clip = video_clip.set_audio(audio_clip)
            video_clip.fps = 24
            clips.append(video_clip)

        if not clips:
            raise ValueError("No clips created from scenes.")

        # --- D. Concatenate and write final video ---
        final_video = concatenate_videoclips(clips, method="compose")
        final_video.write_videofile(
            output_path,
            fps=24,
            codec="libx264",
            audio_codec="aac",
        )
        return cover_image_path
    finally:
        # Close clips & audio to release file handles
        for clip in clips:
            try:
                if clip.audio:
                    clip.audio.close()
                clip.close()
            except Exception:
                pass

        # Cleanup temp files
        for path in temp_files:
            try:
                if os.path.exists(path):
                    os.remove(path)
            except Exception:
                pass