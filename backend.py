from flask import Flask, request, jsonify
from flask_cors import CORS
from clip_model import ImageSearcher
import base64
import os
import pyrebase
from stream import connect
import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth as admin_auth

 
app = Flask(__name__)
CORS(app) # Enable CORS for all domains

cred = credentials.Certificate('/Users/justinsong/snapseek/snapseek/lib/snapseek-cf1e8-firebase-adminsdk-i2zxh-c41f671a21.json')
firebase_admin.initialize_app(cred)

STREAM_API_KEY = os.environ["STREAM_API_KEY"]
STREAM_API_SECRET = os.environ["STREAM_API_SECRET"]
STREAM_APP_ID = os.environ["STREAM_APP_ID"]
FIREBASE_API_KEY = os.environ["FIREBASE_API_KEY"]
FIREBASE_APP_ID = os.environ["FIREBASE_APP_ID"]
FIREBASE_SENDER_ID = os.environ["FIREBASE_SENDER_ID"]

firebase_config = {
    "apiKey": FIREBASE_API_KEY,
    "authDomain": "snapseek-cf1e8.firebaseapp.com",
    "storageBucket": "snapseek-cf1e8.appspot.com",
    "projectId": "snapseek-cf1e8",
    "appId": FIREBASE_APP_ID,
    "messagingSenderId": FIREBASE_SENDER_ID,
    "databaseURL": "https://snapseek-cf1e8.firebaseio.com",
}

firebase = pyrebase.initialize_app(firebase_config)
pyrebase_auth = firebase.auth()

client = connect(STREAM_API_KEY, STREAM_API_SECRET, STREAM_APP_ID)

# Define the upload folder path (replace with Firebase later)
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploaded_photos')
os.makedirs(UPLOAD_FOLDER, exist_ok=True) 

#Initialize CLIP model
searcher = ImageSearcher(model_name = 'ViT-B/32') # Vision Transformer model (32 x 32 pixels)

@app.route('/get_stream_token', methods=['POST'])
def get_stream_token():
    try:
        data = request.json
        firebase_token = data['firebase_token']
        user_id = data['user_id']
        decoded_token = admin_auth.verify_id_token(firebase_token)
        if decoded_token['uid'] != user_id:
            return jsonify({'error': "User ID doesn't match token"}), 400

        stream_token = client.create_user_token(user_id)
        print(stream_token)
        return jsonify({'stream_token': stream_token}), 200
    except KeyError as e:
        return jsonify({'error': 'Malformed data, missing ' + str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 401


"""
    Endpoint to process and save uploaded images.
    
    Receives a JSON payload with base64-encoded images, decodes them, and saves them to the specified directory.
    
    @return: JSON response indicating success or failure.
"""
@app.route('/process-images', methods=['POST'])
def process_images():
    data = request.get_json()
    photos = data.get('photos', [])
    if not photos:
        return jsonify({'error': 'No photos provided!'}), 400

    # Decode photos and save or process them
    for idx, photo in enumerate(photos):
        photo_data = base64.b64decode(photo)
        file_path = os.path.join('/path/to/save', f'photo_{idx}.jpg')
        with open(file_path, 'wb') as f:
            f.write(photo_data)

    return jsonify({'message': 'Photos processed successfully!'}), 200


"""
    Endpoint to search for images based on a description.
    
    Receives a JSON payload with a description and an optional number specifying how many top matching images to return.
    Uses the CLIP model to search for and return the top matching images.
    
    @return: JSON response with the top matching images or an error message.
"""
@app.route('/search', methods=['POST'])
def search_images():
    data = request.get_json()
    description = data.get('description', '')
    numImages = data.get('numImages', 5)  # Default to 5 images if not specified
    
    if not description:
        return jsonify({'error': 'Description is required'}), 400

    # Use the CLIP model to search for the top matching images
    try:
        top_images = searcher.search(description, UPLOAD_FOLDER, numImages)
        return jsonify({'images': top_images}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
    

