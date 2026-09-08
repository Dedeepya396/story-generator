import httpx
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel
from deep_translator import GoogleTranslator
from app.services.ai4bharat_service import call_translation_worker

router = APIRouter(prefix="/subtitles", tags=["Subtitles"])

DEEP_TRANSLATE_CODES = {
    "hindi": "hi",
    "telugu": "te",
    "tamil": "ta",
    "malayalam": "ml",
    "kannada": "kn",
    "bengali": "bn",
    "gujarati": "gu",
    "marathi": "mr",
    "punjabi": "pa",
    "odia": "or",
    "assamese": "as",
    "english": "en",
}


@router.get("/fetch", response_class=PlainTextResponse)
async def fetch_subtitle(url: str = Query(..., description="The Cloudinary VTT URL to fetch")):
    """
    Proxy endpoint: fetches the VTT/SRT file from Cloudinary (or any URL)
    and returns its text content. Avoids CORS issues in Flutter Web.
    """
    if not url.startswith("http"):
        raise HTTPException(status_code=400, detail="Invalid URL")

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(url)
        if resp.status_code != 200:
            raise HTTPException(
                status_code=502,
                detail=f"Failed to fetch subtitle file: HTTP {resp.status_code}"
            )
        return resp.text
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=f"Network error fetching subtitle: {e}")


class TranslateRequest(BaseModel):
    text: str
    target_language: str = "hindi"


def _is_error_text(text: str) -> bool:
    if not text or not text.strip():
        return False
    low = text.lower()
    error_signatures = [
        "error 500",
        "server error",
        "that's an error",
        "please try again later",
        "that's all we know",
        "500 (server error)",
        "http 500",
        "500.",
    ]
    return any(sig in low for sig in error_signatures)


class BatchTranslateRequest(BaseModel):
    texts: list[str]
    target_language: str = "hindi"


@router.post("/translate")
async def translate_text_endpoint(req: TranslateRequest):
    """
    Translates English text into target language for live subtitle display.
    Uses ultra-fast GoogleTranslator (<1s). Returns original text if unavailable.
    Does NOT invoke heavy translation worker during video playback.
    """
    if not req.text or not req.text.strip():
        return {"translated_text": ""}
    if req.target_language.lower() == "english":
        return {"translated_text": req.text}

    target_lang = req.target_language.lower()
    code = DEEP_TRANSLATE_CODES.get(target_lang, target_lang)

    try:
        res = GoogleTranslator(source="auto", target=code).translate(req.text)
        if res and not _is_error_text(res):
            return {"translated_text": res}
        print(f"GoogleTranslator returned invalid error text: '{res}'")
    except Exception as e:
        print(f"Fast GoogleTranslator error: {e}")

    return {"translated_text": req.text}


@router.post("/translate_batch")
async def translate_batch_endpoint(req: BatchTranslateRequest):
    """
    Translates a list of subtitle texts in a single batch request for instant subtitle loading (<300ms).
    """
    if not req.texts:
        return {"translated_texts": []}
    if req.target_language.lower() == "english":
        return {"translated_texts": req.texts}

    target_lang = req.target_language.lower()
    code = DEEP_TRANSLATE_CODES.get(target_lang, target_lang)

    try:
        translator = GoogleTranslator(source="auto", target=code)
        # Fast bulk translation by joining texts with delimiter
        delimiter = " ||| "
        combined = delimiter.join(req.texts)
        res = translator.translate(combined)
        if res and not _is_error_text(res):
            parts = [p.strip() for p in res.split("|||")]
            if len(parts) == len(req.texts):
                return {"translated_texts": parts}
            
        # Fallback: translate items using ThreadPoolExecutor for fast parallel execution
        import concurrent.futures
        def _tr(t):
            if not t or not t.strip():
                return t
            try:
                r = translator.translate(t)
                return r if (r and not _is_error_text(r)) else t
            except Exception:
                return t

        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            results = list(executor.map(_tr, req.texts))
        return {"translated_texts": results}

    except Exception as e:
        print(f"Fast batch translation error: {e}")

    return {"translated_texts": req.texts}



