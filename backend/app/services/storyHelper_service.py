import os
import json
from mistralai.client import Mistral
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
        # model="mistral-small-latest",
        model="ministral-8b-latest",
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
        # model="mistral-small-latest",
        model="ministral-8b-latest",
        messages=[{"role":"user","content":prompt}],
        response_format={"type":"json_object"}
    )

    plan = json.loads(response.choices[0].message.content)

    plan["characters"] = characters

    return plan
  
  
def _normalize_character_name(c) -> str:
    """Convert a character reference to a plain string name, regardless of LLM format."""
    if isinstance(c, dict):
        # LLM returned a dict like {"name": "Mia"} or similar — extract any string value
        return str(next(iter(c.values()), "")).strip()
    return str(c).strip()


def _character_description_to_str(val, _depth: int = 0) -> str:
    """Recursively flatten a character description (str, dict, or list) into a short readable string."""
    if _depth > 3:
        return ""  # prevent runaway recursion
    if isinstance(val, dict):
        # Only keep simple string leaf values; skip nested structures beyond depth 1
        parts = []
        for k, v in val.items():
            if isinstance(v, str):
                parts.append(f"{k}: {v}")
            elif isinstance(v, (dict, list)):
                nested = _character_description_to_str(v, _depth + 1)
                if nested:
                    parts.append(nested)
        return ", ".join(parts)
    if isinstance(val, list):
        return ", ".join(_character_description_to_str(item, _depth + 1) for item in val if item)
    return str(val).strip()


def _build_image_prompt(plan: dict, scene: dict) -> str:
    """Build a concise, URL-safe image generation prompt."""
    style = plan.get("style", "Pixar 3D animation")
    scene_text = scene.get("text", "")[:200]
    environment = scene.get("environment", "")[:100]

    # Collect character traits (short)
    chars_in_scene = scene.get("characters_present", [])
    char_parts = []
    for c in chars_in_scene:
        name = _normalize_character_name(c)
        desc = plan.get("characters", {}).get(name)
        if desc:
            flat = _character_description_to_str(desc)
            # keep only first 80 chars of each character description
            char_parts.append(flat[:80])

    char_text = "; ".join(char_parts)

    prompt = f"{style}, children's storybook illustration, cinematic lighting. Scene: {scene_text}. Setting: {environment}."
    if char_text:
        prompt += f" Characters: {char_text}."

    # Cap to 400 chars so the URL stays well within limits
    return prompt[:400]


def generate_scene_image(plan, scene, i, seed):

    prompt = _build_image_prompt(plan, scene)
    print(f"[PROMPT] Scene {i}: {prompt}")

    try:
        image = hf.text_to_image(
            prompt,
            model="black-forest-labs/FLUX.1-schnell",
            seed=seed
        )
    except Exception as e:
        print(f"[ERROR] Image generation failed for scene {i}: {e}")
        image = Image.new("RGB", (1024, 1024), "black")

    return image

def generate_scene_images(plan):

    image_paths = []

    seed = random.randint(0,999999)

    for i,scene in enumerate(plan["scenes"]):

        chars = []

        prompt = _build_image_prompt(plan, scene)
        print(f"[PROMPT] Scene {i}: {prompt}")

        path = f"output/images/scene_{i}.jpg"

        try:
            image = hf.text_to_image(
                prompt,
                model="black-forest-labs/FLUX.1-schnell",
                seed=seed
            )
            image.save(path)
        except Exception as e:
            print(f"[ERROR] Image generation failed for scene {i}: {e}")
            img = Image.new("RGB", (1024, 1024), "black")
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
