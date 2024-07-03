import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;


class PostPage extends StatefulWidget {
  final String? base64Image;
  
  const PostPage({super.key, this.base64Image});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<Token> getStreamToken(String firebaseToken, String userId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_stream_token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firebase_token': firebaseToken,
        'user_id': userId,
      })
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('stream_token')) {
        return Token(jsonResponse['stream_token']);
      } else {
        throw Exception('Stream token not found in response');
      }
    } else {
      throw Exception('Failed to load stream token');
    }
  }

  Future<String> writeBytesToFile(Uint8List bytes, String fileName) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      print("Error writing file: $e");
      throw e;
    }
  }

  /// "Post" a new activity to the "user" feed group.
  Future<void> post() async {
    if (_textEditingController.text.isEmpty || widget.base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption and image are required')),
      );
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    String? firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    Token streamToken = await getStreamToken(firebaseToken!, FirebaseAuth.instance.currentUser!.uid);
    final user = stream_feed.User(id: FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      try {
        await context.feedClient.setUser(user, streamToken);
      } catch (e) {
        print("Error setting user: $e");
        throw e;
      }
    }

    try {
      // Decode base64 to bytes
      final bytes = base64Decode(widget.base64Image!);
      // Write to a temporary file and get the file path
      final filePath = await writeBytesToFile(bytes, 'uploaded_image.png');

      // Use the file path to upload the image
      final uploadController = context.feedUploadController;

      try {
        await uploadController.uploadImage(AttachmentFile(path: filePath));
      } catch (e) {
        print("Error uploading image: $e");
        throw e;
      }
      final media = uploadController.getMediaUris()?.toExtraData();
      try {
        await context.feedBloc.onAddActivity(
          feedGroup: 'user',
          verb: 'post',
          object: _textEditingController.text,
          data: media,
        );
      } catch (e) {
        print("Error posting: $e");
        throw e;
      }
      print("Successfully uploaded image");
      uploadController.clear();
      Navigator.of(context).pop();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageData;
    if (widget.base64Image != null) {
      imageData = base64Decode(widget.base64Image!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 75),
              if (imageData != null)
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(imageData),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
              const SizedBox(height: 40),
              CustomTextField(
                  controller: _textEditingController,
                  hintText: "Add a caption",
                  obscureText: false,
              ),
              const SizedBox(height: 20),
              CustomButton(onTap: post, name: 'Upload'),
            ],
          ),
        ),
      ),
    );
  }
}