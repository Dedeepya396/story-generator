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
        print("Uploading video...")
        
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
        print("Error during video upload:", e)
        return None

def upload_image(file_path, file_name=None):
    try:
        print("Uploading image...")
        
        response = cloudinary.uploader.upload(
            file_path,
            resource_type="image",
            public_id=file_name or "my_uploaded_image",
        )
        
        print("Image Upload Successful!")
        print("Public ID:", response['public_id'])
        print("Image URL:", response['secure_url'])
        return response['secure_url']

    except Exception as e:
        print("Error during image upload:", e)
        return None


def delete_video_from_cloudinary(video_url: str) -> bool:
    """Delete a video from Cloudinary using its URL."""
    try:
        if not video_url:
            print("⚠️ Empty video URL provided")
            return False
        
        import re
        match = re.search(r'/upload/(?:v[\d]+/)?(.+?)(?:\.\w+)?(?:\?.*)?$', video_url)
        if not match:
            print(f"⚠️ Could not extract public_id from URL: {video_url}")
            return False
        
        public_id = match.group(1)
        print(f"🗑️ Deleting video from Cloudinary: {public_id}")
        
        response = cloudinary.uploader.destroy(
            public_id,
            resource_type="video"
        )
        
        if response.get('result') == 'ok':
            print(f"✅ Video deleted successfully: {public_id}")
            return True
        else:
            print(f"❌ Failed to delete video: {response}")
            return False
    
    except Exception as e:
        print(f"❌ Error deleting video from Cloudinary: {e}")
        return False


def delete_image_from_cloudinary(image_url: str) -> bool:
    """Delete an image from Cloudinary using its URL."""
    try:
        if not image_url:
            print("⚠️ Empty image URL provided")
            return False
        
        import re
        match = re.search(r'/upload/(?:v[\d]+/)?(.+?)(?:\.\w+)?(?:\?.*)?$', image_url)
        if not match:
            print(f"⚠️ Could not extract public_id from URL: {image_url}")
            return False
        
        public_id = match.group(1)
        print(f"🗑️ Deleting image from Cloudinary: {public_id}")
        
        response = cloudinary.uploader.destroy(
            public_id,
            resource_type="image"
        )
        
        if response.get('result') == 'ok':
            print(f"✅ Image deleted successfully: {public_id}")
            return True
        else:
            print(f"❌ Failed to delete image: {response}")
            return False
    
    except Exception as e:
        print(f"❌ Error deleting image from Cloudinary: {e}")
        return False