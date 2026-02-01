import json
import os
import requests
from gtts import gTTS
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips
from groq import Groq
from dotenv import load_dotenv
import os
import re


load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def generate_scenes_from_story(story_text, num_scenes=6):
    # print(story_text)
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
{story_text}
"""

    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7
    )
    print("Here is the following response")
    raw_content = response.choices[0].message.content
    match = re.search(r"\[.*\]", raw_content, re.DOTALL)
    if match:
        json_text = match.group()
        return json.loads(json_text)
    else:
        raise ValueError("Could not find JSON in model response")

def create_video(story):
    scenes = generate_scenes_from_story(story)
    clips = []
    
    for i, scene in enumerate(scenes):
        print(f"Processing scene {i+1}...")
        
        # A. Generate Audio (Free)
        tts = gTTS(scene["text"])
        audio_path = f"audio_{i}.mp3"
        tts.save(audio_path)
        audio = AudioFileClip(audio_path)
        
        # B. Generate Image (Free API - Pollinations)
        img_url = f"https://image.pollinations.ai/prompt/{scene['prompt'].replace(' ', '%20')}?width=1024&height=1024&seed={i}&nologo=true"
        img_path = f"image_{i}.jpg"
        img_data = requests.get(img_url).content
        with open(img_path, 'wb') as handler:
            handler.write(img_data)
        
        # C. Create Video Clip
        # We set the duration of the image to match the length of the audio
        clip = ImageClip(img_path).set_duration(audio.duration)
        clip = clip.set_audio(audio)
        clips.append(clip)

    # 4. Join all clips together
    final_video = concatenate_videoclips(clips, method="compose")
    final_video.write_videofile("rabbit_tortoise_story.mp4", fps=24)

    # Cleanup temporary files
    for i in range(len(scenes)):
        os.remove(f"audio_{i}.mp3")
        os.remove(f"image_{i}.jpg")

if __name__ == "__main__":
    # story = input("Enter your story: ")
    print("Enter your story. Press Enter twice (leave a blank line) to finish:")
    
    lines = []
    while True:
        try:
            line = input()
        except EOFError:
            break
            
        # If the line is empty (user pressed Enter twice), stop
        if not line:
            break
        lines.append(line)
    
    # Join the lines back together into one big string
    story = "\n".join(lines)

    print("--- Story Captured ---")
    print(story)
    create_video(story)