import cloudinary
import cloudinary.uploader
import cloudinary.api
from dotenv import load_dotenv
import os

load_dotenv()

cloudinary.config( 
  cloud_name = os.getenv("CLOUD_NAME"), 
  api_key = os.getenv("API_KEY"), 
  api_secret = os.getenv("API_SECRET"),
  secure = True
)

def upload_video(file_path, file_name=None):
    try:
        print("Uploading...")
        
        # 2. Upload the video
        # 'resource_type' must be set to 'video'
        response = cloudinary.uploader.upload(
            file_path,
            resource_type="video",
            public_id=file_name or "my_uploaded_video",  
            chunk_size=6000000,                           
            eager=[                                        # Optional: create a thumbnail/preview automatically
                {"width": 300, "height": 300, "crop": "pad", "audio_codec": "none"}
            ],
            eager_async=True                               # Optional: process transformations in background
        )
        
        # 3. Print the result
        print("Upload Successful!")
        print("Public ID:", response['public_id'])
        print("Video URL:", response['secure_url'])
        return response['secure_url']

    except Exception as e:
        print("Error during upload:", e)

