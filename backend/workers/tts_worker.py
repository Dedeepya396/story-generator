# """
# Standalone TTS worker - runs in tts_env
# """
# import sys
# import json
# import os
# import torch
# import soundfile as sf
# from transformers import AutoModel, AutoTokenizer, AutoConfig
# from nltk.tokenize import sent_tokenize

# DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# SPEAKER_IDS = {
#     "hindi": 16,
#     "tamil": 0,
#     "telugu": 1,
#     "malayalam": 2,
#     "kannada": 3,
#     "bengali": 4,
#     "gujarati": 5,
#     "marathi": 6,
#     "punjabi": 7,
#     "odia": 8,
#     "assamese": 9,
# }

# # Load VITS model once
# print("Loading VITS TTS...", file=sys.stderr)
# model_name = "ai4bharat/vits_rasa_13"
# config = AutoConfig.from_pretrained(model_name, trust_remote_code=True)
# if not hasattr(config, "pad_token_id"):
#     config.pad_token_id = 0

# model = AutoModel.from_pretrained(
#     model_name,
#     config=config,
#     trust_remote_code=True
# ).to(DEVICE)
# model.eval()

# tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
# if tokenizer.pad_token_id is None:
#     tokenizer.pad_token = tokenizer.eos_token or tokenizer.unk_token

# print("✅ VITS TTS ready", file=sys.stderr)


# def clean_text(text: str) -> str:
#     lines = [line.strip() for line in text.splitlines()]
#     return "\n".join([line for line in lines if line])


# def generate_audio(text: str, language: str, output_path: str, speaker_id: int = None):
#     if speaker_id is None:
#         speaker_id = SPEAKER_IDS.get(language.lower(), 0)
    
#     text = clean_text(text)
    
#     try:
#         import nltk
#         nltk.download('punkt', quiet=True)
#     except:
#         pass
    
#     sentences = sent_tokenize(text)
#     audio_segments = []
    
#     for sentence in sentences:
#         inputs = tokenizer(text=sentence, return_tensors="pt")
#         inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
        
#         with torch.no_grad():
#             outputs = model(
#                 inputs["input_ids"],
#                 speaker_id=speaker_id,
#                 emotion_id=0
#             )
        
#         segment = outputs.waveform.squeeze().cpu().numpy()
#         audio_segments.append(segment)
    
#     # Concatenate audio
#     import numpy as np
#     audio = np.concatenate(audio_segments)
    
#     # Save
#     os.makedirs(os.path.dirname(output_path), exist_ok=True)
#     sf.write(output_path, audio, config.sampling_rate)
    
#     return output_path


# if __name__ == "__main__":
#     # Read input from stdin (JSON)
#     input_data = json.loads(sys.stdin.read())
#     text = input_data["text"]
#     language = input_data["language"]
#     output_path = input_data["output_path"]
#     speaker_id = input_data.get("speaker_id")
    
#     # Generate audio
#     result_path = generate_audio(text, language, output_path, speaker_id)
    
#     # Output as JSON
#     print(json.dumps({"audio_path": result_path}))


"""
Standalone TTS worker - runs in tts_env
"""
import sys
import json
import os
import torch
import soundfile as sf
from transformers import AutoModel, AutoTokenizer, AutoConfig
from typing import Tuple, Optional
from nltk.tokenize import sent_tokenize
import nltk
nltk.download('punkt')
nltk.download('punkt_tab')

try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt')

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Updated Speaker mapping from VITS-Rasa-13 screenshot
SPEAKER_GENDER_MAP = {
    "assamese": {"female": 0, "male": 1},
    "bengali": {"female": 2, "male": 3},
    "bodo": {"female": 4, "male": 5},
    "dogri": {"female": 6, "male": 7},
    "kannada": {"female": 8, "male": 9},
    "maithili": {"male": 10},
    "malayalam": {"female": 11},
    "marathi": {"female": 12, "male": 13},
    "nepali": {"female": 14},
    "punjabi": {"female": 15, "male": 16},
    "sanskrit": {"male": 17},
    "tamil": {"female": 18},
    "telugu": {"female": 19},
}

# Legacy fallback for backward compatibility and missing languages like Hindi
LEGACY_SPEAKER_IDS = {
    "hindi": 16,
    "gujarati": 5,
    "odia": 8,
}

# Load VITS model once
print("Loading VITS TTS...", file=sys.stderr)
model_name = "ai4bharat/vits_rasa_13"

# Load config
ai4b_config = AutoConfig.from_pretrained(model_name, trust_remote_code=True)

# Fix missing pad_token_id in config
if not hasattr(ai4b_config, "pad_token_id"):
    ai4b_config.pad_token_id = 0

# Load model with fixed config
model = AutoModel.from_pretrained(
    model_name,
    config=ai4b_config,
    trust_remote_code=True
).to(DEVICE)
model.eval()

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)

# Fix tokenizer padding token if missing
if tokenizer.pad_token_id is None:
    tokenizer.pad_token = tokenizer.eos_token or tokenizer.unk_token

print("✅ VITS TTS ready", file=sys.stderr)


def clean_text(text: str) -> str:
    """Remove extra indentation and blank lines."""
    lines = [line.strip() for line in text.splitlines()]
    return "\n".join([line for line in lines if line])


def get_speaker_id(language: str, gender: str = "female") -> Tuple[Optional[int], bool]:
    """Get the specific speaker ID and whether it's a fallback."""
    lang = language.lower()
    gender = gender.lower()
    
    # 1. Try modern Rasa-13 mapping
    if lang in SPEAKER_GENDER_MAP:
        sid = SPEAKER_GENDER_MAP[lang].get(gender)
        if sid is not None:
            return sid, False
        return None, True # Gender missing = fallback
    
    # 2. Try legacy mapping (Hindi/Gujarati/Odia)
    if lang in LEGACY_SPEAKER_IDS:
        return LEGACY_SPEAKER_IDS[lang], True # Legacy = fallback
        
    return None, True


def generate_audio(text: str, language: str, output_path: str, speaker_id: Optional[int] = None, gender: str = "female") -> Tuple[str, bool]:
    """Generate audio using AI4Bharat VITS."""
    
    is_fallback = False
    # If speaker_id wasn't provided directly, calculate it
    if speaker_id is None:
        speaker_id, is_fallback = get_speaker_id(language, gender)
        
    print(f"Using speaker_id: {speaker_id} (fallback={is_fallback}) for {language} ({gender})", file=sys.stderr)
    
    # Clean text
    text = clean_text(text)
    
    # Split into sentences for better prosody
    sentences = sent_tokenize(text)
    audio_segments = []
    
    for sentence in sentences:
        if not sentence.strip():
            continue
            
        # Tokenize
        inputs = tokenizer(text=sentence, return_tensors="pt")
        inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
        
        # Generate audio
        with torch.no_grad():
            outputs = model(
                inputs["input_ids"],
                speaker_id=speaker_id,
                emotion_id=0
            )
        
        # Extract waveform
        segment = outputs.waveform.squeeze().cpu().numpy()
        audio_segments.append(segment)
    
    # Concatenate all segments
    import numpy as np
    audio = np.concatenate(audio_segments)
    
    # Save to file
    os.makedirs(os.path.dirname(output_path) if os.path.dirname(output_path) else ".", exist_ok=True)
    sf.write(output_path, audio, ai4b_config.sampling_rate)
    
    return output_path, is_fallback


if __name__ == "__main__":
    # Read input from stdin (JSON)
    input_data = json.loads(sys.stdin.read())
    text = input_data["text"]
    language = input_data["language"]
    output_path = input_data["output_path"]
    speaker_id = input_data.get("speaker_id")
    gender = input_data.get("gender", "female")
    
    # Generate audio
    result_path, voice_fallback = generate_audio(text, language, output_path, speaker_id, gender)
    
    # Output as JSON
    print(json.dumps({
        "audio_path": result_path,
        "voice_fallback": voice_fallback
    }))