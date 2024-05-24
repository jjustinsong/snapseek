from flask import Flask, request, jsonify
from flask_cors import CORS
from clip_model import ImageSearcher
import base64
import os
 
app = Flask(__name__)
CORS(app) # Enable CORS for all domains

# Define the upload folder path (replace with Firebase later)
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploaded_photos')
os.makedirs(UPLOAD_FOLDER, exist_ok=True) 

#Initialize CLIP model
searcher = ImageSearcher(model_name = 'ViT-B/32') # Vision Transformer model (32 x 32 pixels)


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
    top_k = data.get('top_k', 5)  # Default to 5 images if not specified
    
    if not description:
        return jsonify({'error': 'Description is required'}), 400

    # Use the CLIP model to search for the top matching images
    try:
        top_images = searcher.search(description, UPLOAD_FOLDER, top_k)
        return jsonify({'images': top_images}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
    
