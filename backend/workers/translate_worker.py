"""
Standalone translation worker - runs in translate_env
"""
import sys
import json
import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from IndicTransToolkit.processor import IndicProcessor
from nltk.tokenize import sent_tokenize

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
}

# Load model once
print("Loading IndicTrans2...", file=sys.stderr)
model_name = "ai4bharat/indictrans2-en-indic-1B"
tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
model = AutoModelForSeq2SeqLM.from_pretrained(
    model_name,
    trust_remote_code=True
).to(DEVICE)
model.eval()
processor = IndicProcessor(inference=True)
print("✅ IndicTrans2 ready", file=sys.stderr)


def translate_sentence(sentence: str, src_lang: str, tgt_lang: str) -> str:
    batch = processor.preprocess_batch(
        [sentence],
        src_lang=src_lang,
        tgt_lang=tgt_lang,
    )
    
    inputs = tokenizer(
        batch,
        padding=True,
        truncation=True,
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
    if target_language.lower() == "english":
        return text
    
    tgt_lang = LANGUAGE_CODES.get(target_language.lower())
    if not tgt_lang:
        raise ValueError(f"Unsupported language: {target_language}")
    
    sentences = sent_tokenize(text)
    translated = [
        translate_sentence(s, "eng_Latn", tgt_lang)
        for s in sentences if s.strip()
    ]
    
    return " ".join(translated)


if __name__ == "__main__":
    # Read input from stdin (JSON)
    input_data = json.loads(sys.stdin.read())
    text = input_data["text"]
    target_lang = input_data["target_language"]
    
    # Translate
    result = translate_text(text, target_lang)
    
    # Output as JSON
    print(json.dumps({"translated_text": result}))