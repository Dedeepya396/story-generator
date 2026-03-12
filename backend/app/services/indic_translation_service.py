"""
Service layer for IndicTrans2 translation
Calls the translate_worker.py running in translate_env via subprocess
"""
import os
import sys
import json
import subprocess
from typing import List, Dict, Optional

# Paths to virtual environments and workers
# __file__ is backend/app/services/indic_translation_service.py
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TRANSLATE_ENV = os.path.join(BACKEND_DIR, "translate_env", "bin", "python")
TRANSLATE_WORKER = os.path.join(BACKEND_DIR, "workers", "translate_worker.py")

# Hardcoded language codes to avoid failing imports from worker
LANGUAGE_CODES = {
    "hindi": "hin_Deva",
    "tamil": "tam_Taml",
    "telugu": "tel_Telu",
    "malayalam": "mal_Mlym",
    "kannada": "kan_Knda",
    "bengali": "ben_Beng",
    "gujarati": "guj_Gujr",
    "marathi": "mar_Deva",
    "punjabi": "pan_Guru",
    "odia": "ory_Orya",
    "assamese": "asm_Beng",
    "english": "eng_Latn"
}

# Supported languages (includes English)
SUPPORTED_INPUT_LANGUAGES = LANGUAGE_CODES

def translate_to_english(text: str, source_language: str = "english") -> str:
    """
    Translate input text from Indic language to English using IndicTrans2 worker.
    
    Args:
        text: Input text in any supported language
        source_language: Source language name (e.g., 'hindi', 'tamil', 'english')
    
    Returns:
        Translated English text (or original if already English)
    """
     
    print(f"\n{'='*70}")
    print(f"INDIC → ENGLISH TRANSLATION")
    print(f"Source Language: {source_language}")
    print(f"Target Language: English")
    print(f"{'='*70}")
    print(f"Original Text ({source_language}):")
    print(f"   {text}")
    print(f"{'-'*70}")
    # If already English, return as-is
    if source_language.lower() == "english":
        return text
    
    # Check if translation environment exists
    if not os.path.exists(TRANSLATE_ENV):
        print(f"⚠️ Warning: Translation environment not found at {TRANSLATE_ENV}")
        return text
    
    # Check if language is supported
    if source_language.lower() not in SUPPORTED_INPUT_LANGUAGES:
        print(f"⚠️ Warning: Unsupported language '{source_language}', using original text")
        return text
    
    try:
        print(f"🔄 Translating from {source_language} to English via subprocess...")
        
        input_data = json.dumps({
            "text": text,
            "source_language": source_language.lower(),
            "operation": "reverse_translate"
        })
        
        result = subprocess.run(
            [TRANSLATE_ENV, TRANSLATE_WORKER],
            input=input_data,
            capture_output=True,
            text=True,
            check=True
        )
        
        output = json.loads(result.stdout)
        translated = output.get("translated_text", text)
        
        print(f"✅ Translation complete!")
        translated_text = translated
        print(f"Translated Text (English):")
        print(f"   {translated_text}")
        print(f"{'='*70}\n")
        
        return translated
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Translation worker error: {e.stderr}")
        return text
    except Exception as e:
        print(f"❌ Translation error: {e}")
        import traceback
        traceback.print_exc()
        # Fallback: return original text
        return text


def translate_from_english(text: str, target_language: str = "english") -> str:
    """
    Translate English text to Indic language using worker.
    (Note: This is mostly handled by ai4bharat_service.py now)
    """
    if target_language.lower() == "english":
        return text
        
    if not os.path.exists(TRANSLATE_ENV):
        return text
        
    try:
        input_data = json.dumps({
            "text": text,
            "target_language": target_language.lower(),
            "operation": "translate"
        })
        
        result = subprocess.run(
            [TRANSLATE_ENV, TRANSLATE_WORKER],
            input=input_data,
            capture_output=True,
            text=True,
            check=True
        )
        
        output = json.loads(result.stdout)
        return output.get("translated_text", text)
        
    except Exception as e:
        print(f"❌ Translation error: {e}")
        return text


def get_supported_languages():
    """Return list of supported input/output languages"""
    return list(SUPPORTED_INPUT_LANGUAGES.keys())


def is_translation_available():
    """Check if translation service is available"""
    return os.path.exists(TRANSLATE_ENV) and os.path.exists(TRANSLATE_WORKER)
