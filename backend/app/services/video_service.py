import os
import requests
from gtts import gTTS
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips

from app.services.scene_service import generate_scenes

def generate_story_video(story: str, output_path: str):
    scenes = generate_scenes(story)
    clips = []

    for i, scene in enumerate(scenes):
        print(f"processing scene {i+1}")
        audio_path = f"audio_{i}.mp3"
        image_path = f"image_{i}.jpg"

        # TTS
        gTTS(scene["text"]).save(audio_path)

        # Image
        img_url = (
            f"https://image.pollinations.ai/prompt/"
            f"{scene['prompt'].replace(' ', '%20')}?seed={i}&nologo=true"
        )
        img = requests.get(img_url).content
        with open(image_path, "wb") as f:
            f.write(img)

        # Video clip
        audio = AudioFileClip(audio_path)
        clip = ImageClip(image_path).set_duration(audio.duration)
        clip = clip.set_audio(audio)
        clips.append(clip)

    final = concatenate_videoclips(clips, method="compose")
    final.write_videofile(output_path, fps=24)

    # cleanup
    for i in range(len(scenes)):
        os.remove(f"audio_{i}.mp3")
        os.remove(f"image_{i}.jpg")
