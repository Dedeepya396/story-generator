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

    For each character define a strong visual DNA and their gender.

    Return JSON:

    {{
      "characters": {{
         "name": {{
             "visual_dna": "visual description",
             "gender": "male or female or neutral"
         }}
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
    You are a storyboard artist and dialogue adapter.

    IMPORTANT RULES:
    1. PRESERVE NARRATION: If the story has narrative/descriptive sentences (e.g., setting the scene, describing actions), you MUST include them as their own scenes with the speaker set to "narrator". Do NOT skip ANY sentences from the original story.
    2. CONVERT TO DIALOGUE: If a part is written in passive voice or indirect speech, rewrite it into active voice dialogue spoken by the character.
    3. DO NOT ALTER CONTENT: Do not add new information or remove important details. Keep the story exactly the same length and flow. Ensure smooth transitions between narration and dialogue.
    4. NO SPEAKER LABELS IN TEXT: The "text" field MUST contain ONLY the exact words to be spoken aloud. Do NOT prepend the character's name to the text (e.g., output "Let's go!", NEVER output "Rohan: Let's go!").

    Characters:

    {char_text}

    Return JSON:

    {{
      "style":"Pixar cinematic 3D animation",
      "scenes":[
        {{
          "text":"The raw words to be spoken aloud. NO speaker names or colons in this field.",
          "speaker": "Name of the character speaking, or 'narrator'",
          "speaker_gender": "male, female, or narrator",
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

    speaker_info = f"Active Speaker: {scene.get('speaker', 'narrator')} is currently speaking or in focus." if scene.get('speaker', 'narrator') != 'narrator' else "This is a general narration scene."

    prompt = f"""
    {plan["style"]}

    IMPORTANT:
    The characters must look EXACTLY the same in every scene.
    {speaker_info}

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

        speaker_info = f"Active Speaker: {scene.get('speaker', 'narrator')} is currently speaking or in focus." if scene.get('speaker', 'narrator') != 'narrator' else "This is a general narration scene."

        prompt = f"""
        {plan["style"]}

        IMPORTANT:
        The characters must look EXACTLY the same in every scene.
        {speaker_info}

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
