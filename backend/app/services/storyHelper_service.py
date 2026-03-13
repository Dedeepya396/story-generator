import os
import json
import os
from mistralai import Mistral
from dotenv import load_dotenv
from huggingface_hub import InferenceClient
from PIL import Image
import random
from gtts import gTTS
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips


load_dotenv()

client = Mistral(api_key=os.getenv("MISTRAL_API_KEY"))
hf = InferenceClient(token=os.getenv("HF_TOKEN"))


def extract_characters(story):

    prompt = f"""
    Extract ALL recurring characters from the story.

    For each character define a strong visual DNA.

    Return JSON:

    {{
      "characters": {{
         "name":"visual description"
      }}
    }}

    Story:
    {story}
    """

    response = client.chat.complete(
        model="mistral-large-latest",
        messages=[{"role":"user","content":prompt}],
        response_format={"type":"json_object"}
    )

    data = json.loads(response.choices[0].message.content)

    return data["characters"]
  

def plan_scenes(story, characters):

    char_text = "\n".join(
        [f"{name}: {dna}" for name,dna in characters.items()]
    )

    prompt = f"""
    You are a storyboard artist.

    IMPORTANT RULES:
    - DO NOT rewrite or expand the story
    - DO NOT add new sentences
    - ONLY split the existing story into scenes
    - Each scene narration must come DIRECTLY from the story

    Characters:

    {char_text}

    Return JSON:

    {{
      "style":"Pixar cinematic 3D animation",
      "scenes":[
        {{
          "text":"exact sentence from the story",
          "environment":"short description of environment",
          "characters_present":[]
        }}
      ]
    }}

    Story:
    {story}
    """

    response = client.chat.complete(
        model="mistral-large-latest",
        messages=[{"role":"user","content":prompt}],
        response_format={"type":"json_object"}
    )

    plan = json.loads(response.choices[0].message.content)

    plan["characters"] = characters

    return plan
  
  
def generate_scene_image(plan, scene, i, seed):

    chars = []

    for c in scene["characters_present"]:
        if c in plan["characters"]:
            chars.append(plan["characters"][c])

    flattened = []
    for val in chars:
        if isinstance(val, dict):
            flattened.append(", ".join(f"{k}: {v}" for k, v in val.items()))
        else:
            flattened.append(str(val))

    char_text = ", ".join(flattened) if flattened else ""

    prompt = f"""
    {plan["style"]}

    IMPORTANT:
    The characters must look EXACTLY the same in every scene.

    Character design:
    {char_text}

    Scene description:
    {scene["text"]}

    Environment:
    {scene["environment"]}

    cinematic lighting
    children's storybook illustration
    ultra detailed
    consistent character design
    """

    # path = f"output/images/scene_{i}.jpg"

    try:

        image = hf.text_to_image(
            prompt,
            model="black-forest-labs/FLUX.1-schnell",
            seed=seed
        )

        # image.save(path)

    except Exception:

        image = Image.new("RGB",(1024,1024),"black")
        # img.save(path)

    return image

def generate_scene_images(plan):

    image_paths = []

    seed = random.randint(0,999999)

    for i,scene in enumerate(plan["scenes"]):

        chars = []

        for c in scene["characters_present"]:
            if c in plan["characters"]:
                chars.append(plan["characters"][c])

        # char_text = ", ".join(chars)
        flattened = []
        for val in chars:
            if isinstance(val, dict):
                # flatten dict into 'k: v' pieces
                flattened.append(", ".join(f"{k}: {v}" for k, v in val.items()))
            else:
                flattened.append(str(val))

        char_text = ", ".join(flattened) if flattened else ""

        prompt = f"""
        {plan["style"]}

        IMPORTANT:
        The characters must look EXACTLY the same in every scene.

        Character design:
        {char_text}

        Scene description:
        {scene["text"]}

        Environment:
        {scene["environment"]}

        cinematic lighting
        children's storybook illustration
        ultra detailed
        consistent character design
        """

        path = f"output/images/scene_{i}.jpg"

        try:

            image = hf.text_to_image(
                prompt,
                model="black-forest-labs/FLUX.1-schnell",
                seed=seed
            )

            image.save(path)

        except Exception:

            img = Image.new("RGB",(1024,1024),"black")
            img.save(path)

        image_paths.append(path)

    return image_paths
  

def generate_audio(plan):

    audio_paths = []

    for i,scene in enumerate(plan["scenes"]):

        path = f"output/audio/scene_{i}.mp3"

        tts = gTTS(scene["text"])
        tts.save(path)

        audio_paths.append(path)

    return audio_paths
  

def build_video(images, audio):

    clips = []

    for img,aud in zip(images,audio):

        audio_clip = AudioFileClip(aud)

        clip = ImageClip(img).set_duration(audio_clip.duration)

        clip = clip.set_audio(audio_clip)

        clips.append(clip)

    final = concatenate_videoclips(clips, method="compose")

    final.write_videofile(
        "output/final_story.mp4",
        fps=24,
        codec="libx264"
    )
