# import sys
# import os

# # Add parent directory to path
# sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# from app.services.ai4bharat_service import generate_multilingual_audio

# # Test Hindi
# text = "Once the Wind and the Sun had an argument."
# output_path = os.path.join(os.path.dirname(__file__), "test_hindi.wav")

# translated, audio = generate_multilingual_audio(
#     english_text=text,
#     target_language="hindi",
#     output_path=output_path
# )

# print(f"Original: {text}")
# print(f"Translated: {translated}")
# print(f"Audio: {audio}")

import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.ai4bharat_service import generate_multilingual_audio

# Test Hindi
text = "Once the Wind and the Sun had an argument."
output_path = os.path.join(os.path.dirname(__file__), "test_hindi.wav")

print("Testing multilingual pipeline...")
translated, audio = generate_multilingual_audio(
    english_text=text,
    target_language="hindi",
    output_path=output_path
)

print(f"\n✅ Original: {text}")
print(f"✅ Translated: {translated}")
print(f"✅ Audio saved: {audio}")