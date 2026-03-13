import json
import os
import time
import shutil
from typing import List, Dict
import re, json, difflib
from typing import Tuple, Optional

from dotenv import load_dotenv
from gtts import gTTS
from groq import Groq
from huggingface_hub import InferenceClient
from moviepy.editor import ImageClip, AudioFileClip, concatenate_videoclips
from mistralai import Mistral
import random
# Import AI4Bharat service
from app.services.ai4bharat_service import generate_multilingual_audio
from app.services.indic_translation_service import translate_to_english  
from app.services.storyHelper_service import extract_characters, plan_scenes, generate_scene_image



# Import AI4Bharat service
from app.services.ai4bharat_service import generate_multilingual_audio
from app.services.indic_translation_service import translate_to_english  



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


ALLOWED_GENRES = [
    "Adventure",
    "Friendship",
    "Moral",
    "Fantasy",
    "Slice-of-life",
    "Comedy",
    "Drama",
    "Educational",
    "Animal",
    "Mystery",
    "Sci-Fi",
    "Romance",
    "Other"
]


def _normalize_genre(raw: Optional[str]) -> str:
    if not raw:
        return "Other"
    raw = raw.strip()
    # exact match (case-insensitive)
    for g in ALLOWED_GENRES:
        if raw.lower() == g.lower():
            return g
    # fuzzy match
    matches = difflib.get_close_matches(raw, ALLOWED_GENRES, n=1, cutoff=0.6)
    if matches:
        return matches[0]
    # try to extract a single word and retry
    simple = re.sub(r'[^A-Za-z ]', '', raw).split()
    if simple:
        s = simple[0]
        matches = difflib.get_close_matches(s, ALLOWED_GENRES, n=1, cutoff=0.6)
        if matches:
            return matches[0]
    return "Other"


def _generate_title_and_genre(story_text: str) -> Tuple[Optional[str], Optional[str]]:
    prompt = f"""
Given the children's story below, propose:
1) a short descriptive title (<= 6 words),
2) a single-word or short genre chosen from this allowed list: {ALLOWED_GENRES}

Return STRICT JSON only, for example:
{{ "title": "Rusty's Carrot Adventure", "genre": "Friendship" }}

Story:
{story_text}
"""
    try:
        resp = client.chat.complete(
            model="mistral-large-latest",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
        )
        raw = resp.choices[0].message.content or ""
        # extract JSON substring
        m = re.search(r'(\{.*\})', raw, re.S)
        json_text = m.group(1) if m else raw
        try:
            parsed = json.loads(json_text)
        except json.JSONDecodeError:
            # try simple fixes
            fixed = json_text.replace("'", '"')
            fixed = re.sub(r',\s*(?=[}\]])', '', fixed)
            parsed = json.loads(fixed)
            
        title = parsed.get("title")
        raw_genre = parsed.get("genre")
        genre = _normalize_genre(raw_genre)
        if isinstance(title, str):
            title = title.strip()
        return title, genre
    except Exception as e:
        print(f"_generate_title_and_genre failed: {e}")
        return None, "Other"


# def generate_story_video(story: str, output_path: str , language: str = "english") -> str:
def generate_story_video(
    story: str, 
    output_path: str, 
    language: str = "english",          # Output language for audio
    input_language: str = "english",    # ADD THIS PARAMETER
    gender: str = "female"              # New gender parameter
) -> Tuple[str, Optional[str], Optional[str], bool]:  # Added bool for voice_fallback
    """
    Main entry used by the FastAPI route.
    Generates a video file at `output_path` from the given story text.
    Returns the path to the first image (cover image).
    """
    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    cover_image_path = ""
    
     
    # ADD TRANSLATION STEP
    english_story = story
    if input_language.lower() != "english":
        print(f"\n{'='*70}")
        print(f"TRANSLATION: {input_language} → English")
        print(f"{'='*70}")
        
        english_story = translate_to_english(story, input_language)
        
        # print(f"\nOriginal ({input_language}):")
        # print(f"   {story[:150]}...")
        # print(f"\nTranslated (English):")
        # print(f"   {english_story[:150]}...")
        # print(f"{'='*70}\n")
    
        print(f"\nOriginal ({input_language}):")
        print(f"   {story}")
        print(f"\nTranslated (English):")
        print(f"   {english_story}")
        print(f"{'='*70}\n")
    
    # generate title and genre
    # title, genre = _generate_title_and_genre(story)
    # print(f"Generated Title: {title}, Genre: {genre}")
    title, genre = _generate_title_and_genre(english_story)
    print(f"Generated Title: {title}, Genre: {genre}")

    print("\nSTEP 1 — Extract Characters")
    characters = extract_characters(english_story)

    print("\nSTEP 2 — Scene Planning")
    plan = plan_scenes(english_story, characters)

    # Convert plan into scenes format used later
    # scenes = plan
    if isinstance(plan, dict) and "scenes" in plan:
        scenes = plan["scenes"]
    else:
        scenes = plan
    
    # scenes = _generate_scenes_from_story(english_story)
    # if not scenes:
    #     raise ValueError("No scenes generated from story.")

    clips = []
    temp_files: List[str] = []
    any_voice_fallback = False

    try:
        for i, scene in enumerate(scenes):
            print(f"\n{'#'*70}")
            print(f"PROCESSING SCENE {i+1}/{len(scenes)}")
            print(f"{'#'*70}")
            # --- A. Audio with gTTS ---
            audio_path = os.path.join("output", "videos", f"tmp_audio_{i}.mp3")
            os.makedirs(os.path.dirname(audio_path), exist_ok=True)
            
            # Check if we need translation + Indic TTS
            if language.lower() != "english":
                # Use AI4Bharat pipeline (Translation + VITS TTS)
                print(f"Scene {i}: Translating to {language}...")
                translated_text, indic_audio_path, voice_fallback = generate_multilingual_audio(
                    english_text=scene["text"],
                    target_language=language,
                    output_path=audio_path,
                    gender=gender
                )
                if voice_fallback:
                    any_voice_fallback = True
                
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

            # try:
            print(f"Generating image for scene {i}...")
               
            seed = random.randint(0,999999)
            image = generate_scene_image(plan, scene, i, seed)
            image.save(img_path)

            
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
    
    return cover_image_path, title, genre, any_voice_fallback