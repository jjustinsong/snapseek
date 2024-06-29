from flask import Flask, request, jsonify
import pyrebase
from stream import connect
import os

app = Flask(__name__)

firebase_config = {
    "apiKey": "AIzaSyA6FIjy5DqtS5EPZwuS9PsFNcXv47PKk6k",
    "authDomain": "snapseek-cf1e8.firebaseapp.com",
    "storageBucket": "snapseek-cf1e8.appspot.com",
    "projectId": "snapseek-cf1e8",
    "appId": "1:119430690777:android:2fb583200eabd550e64bc8",
    "messagingSenderId": "119430690777",
    "databaseURL": "https://snapseek-cf1e8.firebaseio.com",
}

firebase = pyrebase.initialize_app(firebase_config)
auth = firebase.auth()

stream_api_key = 'wknqxgxtxyyu'
stream_api_secret = 'ads6dtvydvjhptjaapujkva8sytgp9npbgnpd2r2na8n99yhkt8m6gsruhdgqjua'
stream_app_id = '1318996'
client = connect(stream_api_key, stream_api_secret)

@app.route('/get_stream_token', methods=['POST'])
def get_stream_token():
    firebase_token = request.json['firebase_token']
    user_id = request.json['user_id']
    try:
        decoded_token = auth.verify_id_token(firebase_token)
        if decoded_token['uid'] != user_id:
            return jsonify({'error': "User ID doesn't match token"}), 400

        stream_token = client.create_user_token(user_id)
        return jsonify({'stream_token': stream_token}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 401

if __name__ == '__main__':
    app.run(debug = True)
