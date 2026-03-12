"""
Test script for IndicTrans2 translation
Run: python scripts/test_translation.py
"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from workers.translate_worker import translate_text, translate_indic_to_english


def print_separator(title=""):
    print("\n" + "="*70)
    if title:
        print(f"  {title}")
        print("="*70)


def test_hindi_to_english():
    print_separator("TEST 1: Hindi → English")
    
    hindi_text = """एक बार की बात है, एक छोटा सा खरगोश जंगल में रहता था।
वह बहुत ही प्यारा और दोस्ताना था।
एक दिन उसे एक गाजर मिली और वह बहुत खुश हुआ।"""
    
    print(f"\n📝 Original (Hindi):")
    print(f"   {hindi_text[:100]}...")
    
    result = translate_indic_to_english(hindi_text, "hindi")
    
    print(f"\n✅ Translated (English):")
    print(f"   {result[:100]}...")
    print(f"\n📊 Length: {len(hindi_text)} → {len(result)} chars")


def test_english_to_hindi():
    print_separator("TEST 2: English → Hindi")
    
    english_text = """Once upon a time, there was a little rabbit who lived in the forest.
He was very cute and friendly.
One day he found a carrot and was very happy."""
    
    print(f"\n📝 Original (English):")
    print(f"   {english_text[:100]}...")
    
    result = translate_text(english_text, "hindi")
    
    print(f"\n✅ Translated (Hindi):")
    print(f"   {result[:100]}...")


def test_tamil_to_english():
    print_separator("TEST 3: Tamil → English")
    
    tamil_text = """ஒரு காலத்தில், ஒரு சிறிய முயல் காட்டில் வாழ்ந்தது.
அது மிகவும் அழகாகவும் நட்பாகவும் இருந்தது.
ஒரு நாள் அதற்கு ஒரு கேரட் கிடைத்தது."""
    
    print(f"\n📝 Original (Tamil):")
    print(f"   {tamil_text[:80]}...")
    
    result = translate_indic_to_english(tamil_text, "tamil")
    
    print(f"\n✅ Translated (English):")
    print(f"   {result[:100]}...")


def test_english_to_tamil():
    print_separator("TEST 4: English → Tamil")
    
    english_text = """Once upon a time, a small rabbit lived in the forest.
It was very beautiful and friendly."""
    
    print(f"\n📝 Original (English):")
    print(f"   {english_text}")
    
    result = translate_text(english_text, "tamil")
    
    print(f"\n✅ Translated (Tamil):")
    print(f"   {result}")


def test_service_layer():
    print_separator("TEST 5: Service Layer Integration")
    
    try:
        from app.services.indic_translation_service import (
            translate_to_english,
            get_supported_languages,
            is_translation_available
        )
        
        print(f"\n📋 Translation Available: {is_translation_available()}")
        print(f"\n🌐 Supported Languages:")
        for lang in get_supported_languages():
            print(f"   • {lang}")
        
        # Test translation via service
        hindi_text = "नमस्ते, यह एक परीक्षण है।"
        print(f"\n🔄 Testing service layer translation...")
        print(f"   Input (Hindi): {hindi_text}")
        
        result = translate_to_english(hindi_text, "hindi")
        print(f"   Output (English): {result}")
        
    except ImportError as e:
        print(f"\n⚠️ Service layer not available: {e}")


def run_all_tests():
    print("\n" + "🚀 STARTING INDICTRANS2 TRANSLATION TESTS")
    
    try:
        test_hindi_to_english()
        test_english_to_hindi()
        test_tamil_to_english()
        test_english_to_tamil()
        test_service_layer()
        
        print_separator("✅ ALL TESTS COMPLETED SUCCESSFULLY!")
        
    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    run_all_tests()