# """
# Standalone translation worker - runs in translate_env
# """
# import sys
# import json
# import torch
# from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
# from IndicTransToolkit.processor import IndicProcessor
# from nltk.tokenize import sent_tokenize

# DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# LANGUAGE_CODES = {
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
#     "english": "eng_Latn"
# }





# # Global model holders
# en_to_indic_model = None
# en_to_indic_tokenizer = None
# indic_to_en_model = None
# indic_to_en_tokenizer = None
# processor = None




# # Load model once
# print("Loading IndicTrans2...", file=sys.stderr)
# model_name = "ai4bharat/indictrans2-en-indic-1B"
# tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
# model = AutoModelForSeq2SeqLM.from_pretrained(
#     model_name,
#     trust_remote_code=True
# ).to(DEVICE)
# model.eval()
# processor = IndicProcessor(inference=True)
# print("✅ IndicTrans2 ready", file=sys.stderr)





# def translate_sentence(sentence: str, src_lang: str, tgt_lang: str) -> str:
#     batch = processor.preprocess_batch(
#         [sentence],
#         src_lang=src_lang,
#         tgt_lang=tgt_lang,
#     )
    
#     inputs = tokenizer(
#         batch,
#         padding=True,
#         truncation=True,
#         return_tensors="pt"
#     )
#     inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
    
#     with torch.no_grad():
#         generated_tokens = model.generate(
#             **inputs,
#             max_length=256,
#             num_beams=5
#         )
    
#     decoded = tokenizer.batch_decode(
#         generated_tokens,
#         skip_special_tokens=True
#     )
    
#     translations = processor.postprocess_batch(decoded, lang=tgt_lang)
#     return translations[0]


# def translate_text(text: str, target_language: str) -> str:
#     if target_language.lower() == "english":
#         return text
    
#     tgt_lang = LANGUAGE_CODES.get(target_language.lower())
#     if not tgt_lang:
#         raise ValueError(f"Unsupported language: {target_language}")
    
#     sentences = sent_tokenize(text)
#     translated = [
#         translate_sentence(s, "eng_Latn", tgt_lang)
#         for s in sentences if s.strip()
#     ]
    
#     return " ".join(translated)


# if __name__ == "__main__":
#     # Read input from stdin (JSON)
#     input_data = json.loads(sys.stdin.read())
#     text = input_data["text"]
#     target_lang = input_data["target_language"]
    
#     # Translate
#     result = translate_text(text, target_lang)
    
#     # Output as JSON
#     print(json.dumps({"translated_text": result}))


"""
Standalone translation worker - runs in translate_env
Supports both Indic->English and English->Indic translation
"""
import sys
import json
import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from IndicTransToolkit.processor import IndicProcessor
from nltk.tokenize import sent_tokenize

try:
    import nltk
    nltk.download('punkt', quiet=True)
except:
    pass

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

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

# Global model holders
en_to_indic_model = None
en_to_indic_tokenizer = None
indic_to_en_model = None
indic_to_en_tokenizer = None
processor = None


def load_en_to_indic_model():
    """Load English to Indic translation model"""
    global en_to_indic_model, en_to_indic_tokenizer, processor
    
    if en_to_indic_model is None:
        print("Loading IndicTrans2 (English->Indic)...", file=sys.stderr)
        model_name = "ai4bharat/indictrans2-en-indic-1B"
        
        en_to_indic_tokenizer = AutoTokenizer.from_pretrained(
            model_name, 
            trust_remote_code=True
        )
        en_to_indic_model = AutoModelForSeq2SeqLM.from_pretrained(
            model_name,
            trust_remote_code=True,
            torch_dtype=torch.float16 if DEVICE == "cuda" else torch.float32
        ).to(DEVICE)
        en_to_indic_model.eval()
        
        processor = IndicProcessor(inference=True)
        
        print(f"✅ English->Indic model ready on {DEVICE}", file=sys.stderr)


def load_indic_to_en_model():
    """Load Indic to English translation model"""
    global indic_to_en_model, indic_to_en_tokenizer, processor
    
    if indic_to_en_model is None:
        print("Loading IndicTrans2 (Indic->English)...", file=sys.stderr)
        model_name = "ai4bharat/indictrans2-indic-en-1B"
        
        indic_to_en_tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            trust_remote_code=True
        )
        indic_to_en_model = AutoModelForSeq2SeqLM.from_pretrained(
            model_name,
            trust_remote_code=True,
            torch_dtype=torch.float16 if DEVICE == "cuda" else torch.float32
        ).to(DEVICE)
        indic_to_en_model.eval()
        
        if processor is None:
            processor = IndicProcessor(inference=True)
        
        print(f"✅ Indic->English model ready on {DEVICE}", file=sys.stderr)


def translate_sentence(sentence: str, src_lang: str, tgt_lang: str, model, tokenizer) -> str:
    """Translate a single sentence"""
    batch = processor.preprocess_batch(
        [sentence],
        src_lang=src_lang,
        tgt_lang=tgt_lang,
    )
    
    inputs = tokenizer(
        batch,
        padding=True,
        truncation=True,
        max_length=256,
        return_tensors="pt"
    )
    inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
    
    with torch.no_grad():
        generated_tokens = model.generate(
            **inputs,
            max_length=256,
            num_beams=5
        )
    
    decoded = tokenizer.batch_decode(
        generated_tokens,
        skip_special_tokens=True
    )
    
    translations = processor.postprocess_batch(decoded, lang=tgt_lang)
    return translations[0]


def translate_text(text: str, target_language: str) -> str:
    """
    Translate English text to Indic language
    
    Args:
        text: English text
        target_language: Target language name (e.g., 'hindi', 'tamil')
    
    Returns:
        Translated text
    """
    if target_language.lower() == "english":
        return text
    
    # Load model if needed
    load_en_to_indic_model()
    
    # Get target language code
    tgt_lang = LANGUAGE_CODES.get(target_language.lower())
    if not tgt_lang:
        raise ValueError(f"Unsupported target language: {target_language}")
    
    # Split into sentences
    try:
        sentences = sent_tokenize(text)
    except:
        sentences = text.split('.')
        sentences = [s.strip() + '.' for s in sentences if s.strip()]
    
    # Translate each sentence
    translated = []
    for sentence in sentences:
        if sentence.strip():
            trans = translate_sentence(
                sentence, 
                "eng_Latn", 
                tgt_lang,
                en_to_indic_model,
                en_to_indic_tokenizer
            )
            translated.append(trans)
    
    result = " ".join(translated)
    
    print(f"✓ Translated English → {target_language}", file=sys.stderr)
    print(f"  {len(text)} chars → {len(result)} chars", file=sys.stderr)
    
    return result


def translate_indic_to_english(text: str, source_language: str) -> str:
    """
    Translate Indic language text to English
    
    Args:
        text: Text in Indic language
        source_language: Source language name (e.g., 'hindi', 'tamil')
    
    Returns:
        English translated text
    """
    if source_language.lower() == "english":
        return text
    
    # Load model if needed
    load_indic_to_en_model()
    
    # Get source language code
    src_lang = LANGUAGE_CODES.get(source_language.lower())
    if not src_lang:
        raise ValueError(f"Unsupported source language: {source_language}")
    
    # Split into sentences
    try:
        sentences = sent_tokenize(text)
    except:
        # Fallback: simple split
        sentences = text.split('.')
        sentences = [s.strip() + '.' for s in sentences if s.strip()]
    
    # Translate each sentence
    translated = []
    for sentence in sentences:
        if sentence.strip():
            trans = translate_sentence(
                sentence,
                src_lang,
                "eng_Latn",
                indic_to_en_model,
                indic_to_en_tokenizer
            )
            translated.append(trans)
    
    result = " ".join(translated)
    
    print(f"✓ Translated {source_language} → English", file=sys.stderr)
    print(f"  {len(text)} chars → {len(result)} chars", file=sys.stderr)
    
    return result


if __name__ == "__main__":
    """
    CLI usage:
    Input JSON format:
    {
        "text": "input text",
        "target_language": "hindi",  # for en->indic
        "source_language": "hindi",  # for indic->en
        "operation": "translate" or "reverse_translate"
    }
    """
    # Read input from stdin (JSON)
    input_data = json.loads(sys.stdin.read())
    
    text = input_data["text"]
    operation = input_data.get("operation", "translate")
    
    if operation == "translate":
        # English to Indic
        target_lang = input_data.get("target_language", "hindi")
        result = translate_text(text, target_lang)
    elif operation == "reverse_translate":
        # Indic to English
        source_lang = input_data.get("source_language", "hindi")
        result = translate_indic_to_english(text, source_lang)
    else:
        raise ValueError(f"Unknown operation: {operation}")
    
    # Output as JSON
    output = {
        "translated_text": result,
        "operation": operation
    }
    
    print(json.dumps(output))