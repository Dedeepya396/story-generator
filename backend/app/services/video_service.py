# import os
# import requests
# from gtts import gTTS
# from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips

# from app.services.scene_service import generate_scenes

# def generate_story_video(story: str, output_path: str):
#     scenes = generate_scenes(story)
#     clips = []

#     for i, scene in enumerate(scenes):
#         print(f"processing scene {i+1}")
#         audio_path = f"audio_{i}.mp3"
#         image_path = f"image_{i}.jpg"

#         # TTS
#         gTTS(scene["text"]).save(audio_path)

#         # Image
#         img_url = (
#             f"https://image.pollinations.ai/prompt/"
#             f"{scene['prompt'].replace(' ', '%20')}?seed={i}&nologo=true"
#         )
#         img = requests.get(img_url).content
#         with open(image_path, "wb") as f:
#             f.write(img)

#         # Video clip
#         audio = AudioFileClip(audio_path)
#         clip = ImageClip(image_path).set_duration(audio.duration)
#         clip = clip.set_audio(audio)
#         clips.append(clip)

#     final = concatenate_videoclips(clips, method="compose")
#     final.write_videofile(output_path, fps=24)

#     # cleanup
#     for i in range(len(scenes)):
#         os.remove(f"audio_{i}.mp3")
#         os.remove(f"image_{i}.jpg")

# ...existing code...
import os
import io
import requests
import numpy as np
from gtts import gTTS
from PIL import Image
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips
from app.services.scene_service import generate_scenes

def generate_story_video(story: str, output_path: str):
    scenes = generate_scenes(story)
    clips = []

    for idx, scene in enumerate(scenes):
        print(f"processing scene {idx+1}")
        audio_path = f"audio_{idx}.mp3"
        image_path = f"image_{idx}.jpg"

        # 1) Generate TTS audio
        try:
            gTTS(scene["text"]).save(audio_path)
        except Exception as e:
            print(f"Error generating TTS for scene {idx}: {e}")
            # create short silent audio fallback if needed (skip here and continue)
            raise

        # 2) Download image and validate
        img = None
        img_url = (
            f"https://image.pollinations.ai/prompt/"
            f"{scene['prompt'].replace(' ', '%20')}?seed={idx}&nologo=true"
        )

        try:
            resp = requests.get(img_url, timeout=20, headers={"User-Agent": "story-generator/1.0"})
            resp.raise_for_status()

            content_type = resp.headers.get("Content-Type", "")
            if not content_type.startswith("image"):
                raise RuntimeError(f"Response is not an image (Content-Type={content_type})")

            # try to open image from bytes
            img = Image.open(io.BytesIO(resp.content)).convert("RGB")
            # optional: resize to a consistent resolution for the video
            img = img.resize((1024, 1024), Image.LANCZOS)
            img.save(image_path, format="JPEG")
        except Exception as e:
            # Log and create a placeholder image so processing continues
            print(f"Warning: failed to download/parse image for scene {idx}: {e}")
            img = Image.new("RGB", (1024, 1024), color=(200, 200, 200))
            # optional: draw scene text on placeholder for debugging
            try:
                from PIL import ImageDraw, ImageFont
                draw = ImageDraw.Draw(img)
                # default font - don't crash if unavailable
                draw.text((20, 20), f"Scene {idx+1}", fill=(50, 50, 50))
            except Exception:
                pass
            img.save(image_path, format="JPEG")

        # 3) Create video clip from numpy array to avoid imageio backend issues
        try:
            audio = AudioFileClip(audio_path)
            arr = np.array(img)
            clip = ImageClip(arr).set_duration(audio.duration).set_audio(audio)
            clips.append(clip)
        except Exception as e:
            print(f"Error creating clip for scene {idx}: {e}")
            # cleanup partial files for this scene then continue
            try:
                if os.path.exists(audio_path):
                    os.remove(audio_path)
                if os.path.exists(image_path):
                    os.remove(image_path)
            except Exception:
                pass
            raise

    if not clips:
        raise RuntimeError("No clips were created.")

    # 4) Concatenate and write output
    try:
        final = concatenate_videoclips(clips, method="compose")
        final.write_videofile(output_path, fps=24)
    finally:
        # 5) Cleanup temp files
        for i in range(len(scenes)):
            try:
                ap = f"audio_{i}.mp3"
                ip = f"image_{i}.jpg"
                if os.path.exists(ap):
                    os.remove(ap)
                if os.path.exists(ip):
                    os.remove(ip)
            except Exception:
                pass
# ...existing code...