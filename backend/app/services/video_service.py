# # import os
# # import requests
# # from gtts import gTTS
# # from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips

# # from app.services.scene_service import generate_scenes

# # def generate_story_video(story: str, output_path: str):
# #     scenes = generate_scenes(story)
# #     clips = []

# #     for i, scene in enumerate(scenes):
# #         print(f"processing scene {i+1}")
# #         audio_path = f"audio_{i}.mp3"
# #         image_path = f"image_{i}.jpg"

# #         # TTS
# #         gTTS(scene["text"]).save(audio_path)

# #         # Image
# #         img_url = (
# #             f"https://image.pollinations.ai/prompt/"
# #             f"{scene['prompt'].replace(' ', '%20')}?seed={i}&nologo=true"
# #         )
# #         img = requests.get(img_url).content
# #         with open(image_path, "wb") as f:
# #             f.write(img)

# #         # Video clip
# #         audio = AudioFileClip(audio_path)
# #         clip = ImageClip(image_path).set_duration(audio.duration)
# #         clip = clip.set_audio(audio)
# #         clips.append(clip)

# #     final = concatenate_videoclips(clips, method="compose")
# #     final.write_videofile(output_path, fps=24)

# #     # cleanup
# #     for i in range(len(scenes)):
# #         os.remove(f"audio_{i}.mp3")
# #         os.remove(f"image_{i}.jpg")

# # ...existing code...
# import os
# import io
# import requests
# import numpy as np
# from gtts import gTTS
# from PIL import Image
# from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips
# from app.services.scene_service import generate_scenes

# def generate_story_video(story: str, output_path: str):
#     scenes = generate_scenes(story)
#     clips = []

#     for idx, scene in enumerate(scenes):
#         print(f"processing scene {idx+1}")
#         audio_path = f"audio_{idx}.mp3"
#         image_path = f"image_{idx}.jpg"

#         # 1) Generate TTS audio
#         try:
#             gTTS(scene["text"]).save(audio_path)
#         except Exception as e:
#             print(f"Error generating TTS for scene {idx}: {e}")
#             # create short silent audio fallback if needed (skip here and continue)
#             raise

#         # 2) Download image and validate
#         img = None
#         img_url = (
#             f"https://image.pollinations.ai/prompt/"
#             f"{scene['prompt'].replace(' ', '%20')}?seed={idx}&nologo=true"
#         )

#         try:
#             resp = requests.get(img_url, timeout=20, headers={"User-Agent": "story-generator/1.0"})
#             resp.raise_for_status()

#             content_type = resp.headers.get("Content-Type", "")
#             if not content_type.startswith("image"):
#                 raise RuntimeError(f"Response is not an image (Content-Type={content_type})")

#             # try to open image from bytes
#             img = Image.open(io.BytesIO(resp.content)).convert("RGB")
#             # optional: resize to a consistent resolution for the video
#             img = img.resize((1024, 1024), Image.LANCZOS)
#             img.save(image_path, format="JPEG")
#         except Exception as e:
#             # Log and create a placeholder image so processing continues
#             print(f"Warning: failed to download/parse image for scene {idx}: {e}")
#             img = Image.new("RGB", (1024, 1024), color=(200, 200, 200))
#             # optional: draw scene text on placeholder for debugging
#             try:
#                 from PIL import ImageDraw, ImageFont
#                 draw = ImageDraw.Draw(img)
#                 # default font - don't crash if unavailable
#                 draw.text((20, 20), f"Scene {idx+1}", fill=(50, 50, 50))
#             except Exception:
#                 pass
#             img.save(image_path, format="JPEG")

#         # 3) Create video clip from numpy array to avoid imageio backend issues
#         try:
#             audio = AudioFileClip(audio_path)
#             arr = np.array(img)
#             clip = ImageClip(arr).set_duration(audio.duration).set_audio(audio)
#             clips.append(clip)
#         except Exception as e:
#             print(f"Error creating clip for scene {idx}: {e}")
#             # cleanup partial files for this scene then continue
#             try:
#                 if os.path.exists(audio_path):
#                     os.remove(audio_path)
#                 if os.path.exists(image_path):
#                     os.remove(image_path)
#             except Exception:
#                 pass
#             raise

#     if not clips:
#         raise RuntimeError("No clips were created.")

#     # 4) Concatenate and write output
#     try:
#         final = concatenate_videoclips(clips, method="compose")
#         final.write_videofile(output_path, fps=24)
#     finally:
#         # 5) Cleanup temp files
#         for i in range(len(scenes)):
#             try:
#                 ap = f"audio_{i}.mp3"
#                 ip = f"image_{i}.jpg"
#                 if os.path.exists(ap):
#                     os.remove(ap)
#                 if os.path.exists(ip):
#                     os.remove(ip)
#             except Exception:
#                 pass
# # ...existing code...

import json
import os
import time
from typing import List, Dict

from dotenv import load_dotenv
from gtts import gTTS
from groq import Groq
from huggingface_hub import InferenceClient
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips

load_dotenv()

HF_TOKEN = os.getenv("HF_TOKEN")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

if not GROQ_API_KEY:
    raise RuntimeError("GROQ_API_KEY is not set.")
if not HF_TOKEN:
    raise RuntimeError("HF_TOKEN is not set.")

groq_client = Groq(api_key=GROQ_API_KEY)
hf_client = InferenceClient(token=HF_TOKEN)


def _generate_scenes_from_story(story_text: str, num_scenes: int = 6) -> List[Dict]:
    """
    Ask Groq LLM to split story into JSON scenes.
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

    response = groq_client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
    )

    raw_content = response.choices[0].message.content or ""

    start = raw_content.find("[")
    end = raw_content.rfind("]") + 1
    if start == -1 or end == 0:
        raise ValueError(f"Could not find JSON in model response: {raw_content!r}")

    json_text = raw_content[start:end]
    return json.loads(json_text)


def generate_story_video(story: str, output_path: str) -> None:
    """
    Main entry used by the FastAPI route.
    Generates a video file at `output_path` from the given story text.
    """
    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

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

            tts = gTTS(scene["text"])
            tts.save(audio_path)
            temp_files.append(audio_path)

            audio_clip = AudioFileClip(audio_path)

            # --- B. Image with Hugging Face ---
            img_path = os.path.join("output", "videos", f"tmp_image_{i}.jpg")
            temp_files.append(img_path)

            try:
                image = hf_client.text_to_image(
                    scene["prompt"],
                    model="black-forest-labs/FLUX.1-schnell",
                )
                image.save(img_path)

                # Rate limit safety
                time.sleep(10)
            except Exception:
                # Fallback: black image so pipeline doesn’t break
                from PIL import Image

                os.makedirs(os.path.dirname(img_path), exist_ok=True)
                img = Image.new("RGB", (1024, 1024), color="black")
                img.save(img_path)

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