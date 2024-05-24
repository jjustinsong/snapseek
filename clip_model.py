import torch
import os
import clip
import base64
from PIL import Image


class ImageSearcher:
    """
    Class for searching and processing images using the CLIP model.
    """

    def __init__(self, model_name='ViT-B/32', device=None):
        """
        Initializes the image searcher with a specified model and device (GPU/CPU).
        
        :param model_name: The name of the model to load.
        :param device: The device ('cuda' or 'cpu') on which the model should run.
        """
        self.device = device if device else "cuda" if torch.cuda.is_available() else "cpu"
        self.model, self.preprocess = clip.load(model_name, device=self.device)
    
    
    def get_image_paths(self, image_folder):
        """
        Retrieves a list of image file paths from a specified folder that match common image file extensions.
        
        :param image_folder: Path to the folder containing images.
        :return: List of strings, where each string is a path to an image file.
        """
        files = os.listdir(image_folder)
        return [os.path.join(image_folder, file) for file in files if file.lower().endswith(('png', 'jpg', 'jpeg', 'bmp', 'gif', 'tiff'))]
    
    
    def preprocess_images(self, image_paths):
        """
        Processes images by loading them and applying preprocessing suitable for the model.
        
        :param image_paths: List of paths to images.
        :return: A tensor containing processed image data.
        """
        images = []
        for path in image_paths:
            try:
                image = Image.open(path).convert("RGB")
                image = self.preprocess(image).unsqueeze(0).to(self.device)
                images.append(image)
            except (IsADirectoryError, FileNotFoundError, IOError) as e:
                print(f"Skipping {path}: {e}")
        return torch.cat(images) if images else None


    def encode_text(self, description):
        """
        Encodes a text description into a tensor using the CLIP model's text encoder.
        
        :param description: Text description to encode.
        :return: Tensor representing text features.
        """
        text = clip.tokenize([description]).to(self.device)
        with torch.no_grad():
            return self.model.encode_text(text)


    def encode_images(self, images):
        """
        Encodes images into tensors using the CLIP model's image encoder.
        
        :param images: Tensor containing image data to encode.
        :return: Tensor representing image features.
        """
        with torch.no_grad():
            return self.model.encode_image(images)


    def compute_similarity(self, text_features, image_features):
        """
        Computes the cosine similarity between text features and image features.
        
        :param text_features: Tensor of text features.
        :param image_features: Tensor of image features.
        :return: Tensor representing similarity scores between text and images.
        """
        text_features = text_features / text_features.norm(dim=-1, keepdim=True)
        image_features = image_features / image_features.norm(dim=-1, keepdim=True)
        return (100.0 * text_features @ image_features.T).softmax(dim=-1)


    def find_top(self, similarity, image_paths, top_k=5):
        """
        Selects the top-k most similar images based on the computed similarity scores.
        
        :param similarity: Tensor of similarity scores.
        :param image_paths: List of image paths corresponding to the scores.
        :param top_k: Number of top images to return.
        :return: List of paths to the top-k images.
        """
        values, indices = similarity[0].topk(top_k)
        return [image_paths[idx] for idx in indices]


    def search(self, description, image_folder, top_k=5):
        """
        Searches for images in a specified folder that are most relevant to a given description.
        
        :param description: Text description to search for.
        :param image_folder: Folder containing images to search.
        :param top_k: Number of relevant images to return.
        :return: List of Base64-encoded strings of the top-k relevant images.
        """
        # processing photo album
        image_paths = self.get_image_paths(image_folder)
        images = self.preprocess_images(image_paths)
        
        # embeddings & similarity calculation
        text_features = self.encode_text(description)
        image_features = self.encode_images(images)
        similarity = self.compute_similarity(text_features, image_features)
        
        # finding relevant photos
        top_images = self.find_top(similarity, image_paths, top_k=top_k)
        return self.convert_images(top_images)


    def convert_images(self, image_paths):   
        """
        Converts a list of image paths to Base64-encoded strings for easy transmission to frontend.
        
        :param image_paths: List of image paths to convert.
        :return: List of Base64-encoded strings representing the images.
        """
        base64_images = []
        for path in image_paths:
            with open(path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                base64_images.append(encoded_string)
        return base64_images
    
    
    