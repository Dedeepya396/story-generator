# # import os
# # import torch
# # import soundfile as sf
# # from typing import Optional, Tuple
# # from transformers import AutoModel, AutoTokenizer, AutoConfig, AutoModelForSeq2SeqLM
# # from IndicTransToolkit.processor import IndicProcessor
# # from nltk.tokenize import sent_tokenize
# # import nltk


# import os
# import torch
# import soundfile as sf
# import nltk

# from typing import Optional, Tuple
# from transformers import (
#     AutoModel,
#     AutoTokenizer,
#     AutoConfig,
#     AutoModelForSeq2SeqLM
# )
# from IndicTransToolkit.processor import IndicProcessor
# from nltk.tokenize import sent_tokenize

# # Download NLTK data (run once)
# try:
#     nltk.data.find('tokenizers/punkt')
# except LookupError:
#     nltk.download('punkt')

# # -----------------------------------
# # DEVICE CONFIGURATION
# # -----------------------------------
# DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# # -----------------------------------
# # LANGUAGE CODE MAPPING
# # -----------------------------------
# LANGUAGE_CODES = {
#     "english": "eng_Latn",
#     "hindi": "hin_Deva",
#     "tamil": "tam_Taml",
#     "telugu": "tel_Telu",
#     "malayalam": "mal_Mlym",
#     "kannada": "kan_Knda",
#     "bengali": "ben_Beng",
#     "gujarati": "guj_Gujr",
#     "marathi": "mar_Deva",
#     "punjabi": "pan_Guru",
#     "odia": "ory_Orya",
#     "assamese": "asm_Beng",
# }

# # Speaker IDs for AI4Bharat VITS (adjust based on available speakers)
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

# # -----------------------------------
# # LAZY LOADING FOR MODELS
# # -----------------------------------
# class TranslationModel:
#     """Lazy loader for IndicTrans2 translation model."""
#     def __init__(self):
#         self.tokenizer = None
#         self.model = None
#         self.processor = None
        
#     def load(self):
#         if self.model is None:
#             print("Loading IndicTrans2 model...")
#             model_name = "ai4bharat/indictrans2-en-indic-1B"
            
#             self.tokenizer = AutoTokenizer.from_pretrained(
#                 model_name,
#                 trust_remote_code=True
#             )
            
#             self.model = AutoModelForSeq2SeqLM.from_pretrained(
#                 model_name,
#                 trust_remote_code=True,
#                 low_cpu_mem_usage=True
#             ).to(DEVICE)
            
#             self.model.eval()
#             self.processor = IndicProcessor(inference=True)
#             print("✅ IndicTrans2 loaded")


# class TTSModel:
#     """Lazy loader for AI4Bharat VITS TTS model."""
#     def __init__(self):
#         self.model = None
#         self.tokenizer = None
#         self.config = None
        
#     def load(self):
#         if self.model is None:
#             print("Loading AI4Bharat VITS TTS model...")
#             model_name = "ai4bharat/vits_rasa_13"
            
#             self.config = AutoConfig.from_pretrained(model_name, trust_remote_code=True)
            
#             # Fix missing pad_token_id
#             if not hasattr(self.config, "pad_token_id"):
#                 self.config.pad_token_id = 0
            
#             self.model = AutoModel.from_pretrained(
#                 model_name,
#                 config=self.config,
#                 trust_remote_code=True
#             ).to(DEVICE)
            
#             self.tokenizer = AutoTokenizer.from_pretrained(
#                 model_name, 
#                 trust_remote_code=True
#             )
            
#             # Fix tokenizer padding token
#             if self.tokenizer.pad_token_id is None:
#                 self.tokenizer.pad_token = self.tokenizer.eos_token or self.tokenizer.unk_token
            
#             self.model.eval()
#             print("✅ AI4Bharat VITS TTS loaded")


# # Global instances
# translation_model = TranslationModel()
# tts_model = TTSModel()

# # -----------------------------------
# # TEXT CLEANING
# # -----------------------------------
# def clean_text(text: str) -> str:
#     """Clean text for TTS processing."""
#     lines = [line.strip() for line in text.splitlines()]
#     lines = [line for line in lines if line]
#     return "\n".join(lines)


# # -----------------------------------
# # TRANSLATION FUNCTIONS
# # -----------------------------------
# def translate_sentence(sentence: str, src_lang: str, tgt_lang: str) -> str:
#     """Translate a single sentence using IndicTrans2."""
#     translation_model.load()
    
#     batch = translation_model.processor.preprocess_batch(
#         [sentence],
#         src_lang=src_lang,
#         tgt_lang=tgt_lang,
#     )
    
#     inputs = translation_model.tokenizer(
#         batch,
#         padding=True,
#         truncation=True,
#         return_tensors="pt"
#     )

#     inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
        
#     # inputs = translation_model.tokenizer(
#     #     batch,
#     #     padding=True,
#     #     truncation=True,
#     #     return_tensors="pt"
#     # ).to(DEVICE)
    
#     with torch.no_grad():
#         generated_tokens = translation_model.model.generate(
#             **inputs,
#             max_length=256,
#             num_beams=5
#         )
    
#     decoded = translation_model.tokenizer.batch_decode(
#         generated_tokens,
#         skip_special_tokens=True
#     )
    
#     translations = translation_model.processor.postprocess_batch(
#         decoded,
#         lang=tgt_lang
#     )
    
#     return translations[0]


# def translate_text(text: str, target_language: str) -> str:
#     """
#     Translate English text to target Indic language.
    
#     Args:
#         text: English text to translate
#         target_language: Target language name (e.g., 'hindi', 'tamil')
    
#     Returns:
#         Translated text in target language
#     """
#     # If target is English, no translation needed
#     if target_language.lower() == "english":
#         return text
    
#     # Get language codes
#     tgt_lang = LANGUAGE_CODES.get(target_language.lower())
#     if not tgt_lang:
#         raise ValueError(
#             f"Unsupported language: {target_language}. "
#             f"Supported: {list(LANGUAGE_CODES.keys())}"
#         )
    
#     src_lang = "eng_Latn"
    
#     try:
#         # Split text into sentences for better translation
#         sentences = sent_tokenize(text)
        
#         # Translate each sentence
#         translated_sentences = [
#             translate_sentence(s, src_lang, tgt_lang)
#             for s in sentences if s.strip()
#         ]
        
#         return " ".join(translated_sentences)
    
#     except Exception as e:
#         print(f"Translation error: {e}")
#         # Fallback to original text
#         return text


# # -----------------------------------
# # TTS FUNCTIONS
# # -----------------------------------
# def generate_indic_audio(
#     text: str, 
#     language: str, 
#     output_path: str,
#     speaker_id: Optional[int] = None,
#     emotion_id: int = 0
# ) -> str:
#     """
#     Generate audio from Indic language text using AI4Bharat VITS.
    
#     Args:
#         text: Text in target language
#         language: Language name (e.g., 'hindi', 'tamil')
#         output_path: Path to save the generated audio file
#         speaker_id: Speaker ID (if None, uses default for language)
#         emotion_id: Emotion ID (default: 0 for neutral)
    
#     Returns:
#         Path to the generated audio file
#     """
#     tts_model.load()
    
#     # Get default speaker ID for language if not provided
#     if speaker_id is None:
#         speaker_id = SPEAKER_IDS.get(language.lower(), 0)
    
#     # Clean text
#     text = clean_text(text)
    
#     try:
#         # Tokenize input
#         # inputs = tts_model.tokenizer(text=text, return_tensors="pt").to(DEVICE)
#         # inputs = tts_model.tokenizer(text=text, return_tensors="pt")
#         # inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
        
#         # # Generate audio
#         # with torch.no_grad():
#         #     outputs = tts_model.model(
#         #         inputs["input_ids"],
#         #         speaker_id=speaker_id,
#         #         emotion_id=emotion_id
#         #     )
        
#         # # Extract waveform
#         # audio = outputs.waveform.squeeze().cpu().numpy()
#         sentences = sent_tokenize(text)

#         audio_segments = []

#         for sentence in sentences:
#             inputs = tts_model.tokenizer(text=sentence, return_tensors="pt")
#             inputs = {k: v.to(DEVICE) for k, v in inputs.items()}

#             with torch.no_grad():
#                 outputs = tts_model.model(
#                     inputs["input_ids"],
#                     speaker_id=speaker_id,
#                     emotion_id=emotion_id
#                 )

#             segment = outputs.waveform.squeeze().cpu().numpy()
#             audio_segments.append(segment)

#         audio = torch.cat([torch.tensor(a) for a in audio_segments]).numpy()
                
#         # Save as WAV file
#         # os.makedirs(os.path.dirname(output_path), exist_ok=True)
#         output_dir = os.path.dirname(output_path)
#         if output_dir:
#             os.makedirs(output_dir, exist_ok=True)
#         sf.write(output_path, audio, tts_model.config.sampling_rate)
        
#         print(f"✅ Generated audio: {output_path}")
#         return output_path
    
#     except Exception as e:
#         print(f"AI4Bharat TTS error: {e}")
#         raise


# # -----------------------------------
# # COMBINED PIPELINE
# # -----------------------------------
# def generate_multilingual_audio(
#     english_text: str,
#     target_language: str,
#     output_path: str,
#     speaker_id: Optional[int] = None,
#     emotion_id: int = 0
# ) -> Tuple[str, Optional[str]]:
#     """
#     Complete pipeline: Translate English text and generate audio.
    
#     Args:
#         english_text: Original English text
#         target_language: Target language for audio (e.g., 'hindi', 'tamil', 'english')
#         output_path: Path to save audio file
#         speaker_id: Optional speaker ID for TTS
#         emotion_id: Emotion ID for TTS (default: 0)
    
#     Returns:
#         Tuple of (translated_text, audio_file_path or None)
#     """
#     # Step 1: Translate if not English
#     if target_language.lower() != "english":
#         print(f"Translating to {target_language}...")
#         translated_text = translate_text(english_text, target_language)
        
#         # Step 2: Generate audio using AI4Bharat VITS
#         print(f"Generating {target_language} audio...")
        
#         # Convert MP3 path to WAV (VITS outputs WAV)
#         wav_path = output_path.replace('.mp3', '.wav')
#         audio_path = generate_indic_audio(
#             text=translated_text,
#             language=target_language,
#             output_path=wav_path,
#             speaker_id=speaker_id,
#             emotion_id=emotion_id
#         )
        
#         return translated_text, audio_path
#     else:
#         # For English, return text without audio (will use gTTS in video_service)
#         return english_text, None

"""
Worker manager - coordinates translation and TTS workers
"""
import os
import json
import subprocess
from typing import Tuple, Optional

# Paths to virtual environments
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
TRANSLATE_ENV = os.path.join(BACKEND_DIR, "translate_env", "bin", "python")
TTS_ENV = os.path.join(BACKEND_DIR, "tts_env", "bin", "python")
TRANSLATE_WORKER = os.path.join(BACKEND_DIR, "workers", "translate_worker.py")
TTS_WORKER = os.path.join(BACKEND_DIR, "workers", "tts_worker.py")


def call_translation_worker(text: str, target_language: str) -> str:
    """
    Call translation worker in separate environment.
    
    Args:
        text: English text to translate
        target_language: Target language (e.g., 'hindi')
    
    Returns:
        Translated text
    """
    input_data = json.dumps({
        "text": text,
        "target_language": target_language
    })
    print(f"   → Calling translation worker (English → {target_language})...")
 
    
    try:
        result = subprocess.run(
            [TRANSLATE_ENV, TRANSLATE_WORKER],
            input=input_data,
            capture_output=True,
            text=True,
            check=True
        )
        
        output = json.loads(result.stdout)
        translated = output["translated_text"]
        print(f"Translation completed")
        return translated
        # return output["translated_text"]
    
    except subprocess.CalledProcessError as e:
        print(f"Translation worker error: {e.stderr}")
        # Fallback to original text
        return text
    except Exception as e:
        print(f"Translation error: {e}")
        return text


def call_tts_worker(
    text: str,
    language: str,
    output_path: str,
    speaker_id: Optional[int] = None,
    gender: str = "female"
) -> Tuple[str, bool]:
    """
    Call TTS worker in separate environment.
    
    Args:
        text: Text to convert to speech
        language: Language of the text
        output_path: Where to save audio file
        speaker_id: Optional speaker ID
        gender: Selected gender ('male'/'female')
    
    Returns:
        Tuple of (audio_path, voice_fallback)
    """
    input_data = json.dumps({
        "text": text,
        "language": language,
        "output_path": output_path,
        "speaker_id": speaker_id,
        "gender": gender
    })
    print(f"   → Calling TTS worker ({language} audio generation)...")

    
    try:
        result = subprocess.run(
            [TTS_ENV, TTS_WORKER],
            input=input_data,
            capture_output=True,
            text=True,
            check=True
        )
        
        output = json.loads(result.stdout)
        audio_path = output["audio_path"]
        voice_fallback = output.get("voice_fallback", False)
        print(f"TTS generation completed (fallback: {voice_fallback})")
        return audio_path, voice_fallback
    
    except subprocess.CalledProcessError as e:
        print(f"TTS worker error: {e.stderr}")
        raise
    except Exception as e:
        print(f"TTS error: {e}")
        raise


# def generate_multilingual_audio(
#     english_text: str,
#     target_language: str,
#     output_path: str,
#     speaker_id: Optional[int] = None,
#     emotion_id: int = 0
# ) -> Tuple[str, Optional[str]]:
#     """
#     Complete pipeline: Translate English text and generate audio.
    
#     Args:
#         english_text: Original English text
#         target_language: Target language for audio
#         output_path: Path to save audio file
#         speaker_id: Optional speaker ID
#         emotion_id: Unused (for compatibility)
    
#     Returns:
#         Tuple of (translated_text, audio_file_path or None)
#     """
    
#     if target_language.lower() != "english":
#         print(f"Translating to {target_language}...")
#         translated_text = call_translation_worker(english_text, target_language)
#         print(f"Translation: {translated_text}")
        
#         print(f"Generating {target_language} audio...")
#         wav_path = output_path.replace('.mp3', '.wav')
#         audio_path = call_tts_worker(
#             text=translated_text,
#             language=target_language,
#             output_path=wav_path,
#             speaker_id=speaker_id
#         )
        
#         return translated_text, audio_path
#     else:
#         return english_text, None

def generate_multilingual_audio(
    english_text: str,
    target_language: str,
    output_path: str,
    speaker_id: Optional[int] = None,
    emotion_id: int = 0,
    gender: str = "female"
) -> Tuple[str, Optional[str], bool]:
    """
    Complete pipeline: Translate English text and generate audio.
    
    Args:
        english_text: Original English text
        target_language: Target language for audio
        output_path: Path to save audio file
        speaker_id: Optional speaker ID
        emotion_id: Unused (for compatibility)
        gender: 'male' or 'female'
    
    Returns:
        Tuple of (translated_text, audio_file_path or None, voice_fallback)
    """
    
    if target_language.lower() != "english":
        print(f"\n{'='*70}")
        print(f"ENGLISH → {target_language.upper()} TRANSLATION + TTS PIPELINE")
        print(f"{'='*70}")
        print(f"Source Language: English")
        print(f"Target Language: {target_language.title()}")
        print(f"{'='*70}")
        print(f"Original Text (English):")
        print(f"   {english_text}")
        print(f"{'-'*70}")
        
        print(f"Step 1: Translating English → {target_language.title()}...")
        translated_text = call_translation_worker(english_text, target_language)
        
        print(f"Translated Text ({target_language.title()}):")
        print(f"   {translated_text}")
        print(f"{'-'*70}")
        
        print(f"Step 2: Generating {target_language.title()} audio using AI4Bharat VITS TTS...")
        wav_path = output_path.replace('.mp3', '.wav')
        
        audio_path, voice_fallback = call_tts_worker(
            text=translated_text,
            language=target_language,
            output_path=wav_path,
            speaker_id=speaker_id,
            gender=gender
        )
        
        print(f"✅ Audio generated successfully!")
        print(f"   Audio saved to: {audio_path}")
        print(f"{'='*70}\n")
        
        return translated_text, audio_path, voice_fallback
    else:
        print(f"\n{'='*70}")
        print(f"ENGLISH AUDIO PIPELINE (NO TRANSLATION)")
        print(f"{'='*70}")
        print(f"Language: English")
        print(f"Text: {english_text}")
        print(f"Note: Using gTTS for English audio (handled in video_service)")
        print(f"{'='*70}\n")
        
        return english_text, None, False