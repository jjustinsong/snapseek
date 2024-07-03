import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;

class EditProfile extends StatefulWidget {
  String profileImageUrl;
  String username;
  EditProfile({super.key, required this.profileImageUrl, required this.username});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController usernameController = TextEditingController();
  File? _imageFile;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<stream_feed.Token> getStreamToken(String firebaseToken, String userId) async {
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
        return stream_feed.Token(jsonResponse['stream_token']);
      } else {
        throw Exception('Stream token not found in response');
      }
    } else {
      throw Exception('Failed to load stream token');
    }
  }

  Future<void> stream() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print("FirebaseAuth user is null");
      return;
    }
    String? firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (firebaseToken == null) {
      print("Firebase token is null");
      return;
    }
    stream_feed.Token streamToken = await getStreamToken(firebaseToken!, FirebaseAuth.instance.currentUser!.uid);
    final user = stream_feed.User(id: FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      try {
        await context.feedClient.setUser(user, streamToken);
      } catch (e) {
        print("Error setting user: $e");
        throw e;
      }
    }
    print("stream");
  }

  Future<void> refreshStreamUserData() async {
    try {
      // Fetch the latest user data
      var updatedUser = await context.feedClient.user(user!.uid).get();
      
      // Update your state management solution or local state to reflect changes
      setState(() {
        widget.username = updatedUser.data!['handle'] as String;
        widget.profileImageUrl = updatedUser.data!['profileImage'] as String;
      });
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }

  Future<void> saveChanges() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found'))
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
    try {
      String? firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      stream_feed.Token streamToken = await getStreamToken(firebaseToken!, FirebaseAuth.instance.currentUser!.uid);
      Map<String, dynamic> userDataUpdates = {};
      if (usernameController.text.isNotEmpty) {
        userDataUpdates['handle'] = usernameController.text;
        await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'username': usernameController.text});
      }
      if (_imageFile != null) {
        String imageUrl = await uploadImage(_imageFile!);
        await user!.updatePhotoURL(imageUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profileImageUrl': imageUrl});
        userDataUpdates['profileImage'] = imageUrl;
      }
      if (userDataUpdates.isNotEmpty) {
        await context.feedClient.setUser(
          stream_feed.User(id: user!.uid, data: userDataUpdates),
          streamToken
        );
      }
      await refreshStreamUserData();
      Navigator.of(context).pop();
      Navigator.pop(context, true);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e'))
      );
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = 'profile_${user!.uid}';
    final destination = 'profile_images/$fileName';
    final ref = FirebaseStorage.instance.ref(destination);
    print(1);
    try {
      UploadTask uploadTask = ref.putFile(image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Task stateL: ${snapshot.state}');
        print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      }, onError: (e) {
        print('$e');
      });
      await uploadTask;
      print(2);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('$e');
      throw e;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Set temporary file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: [
                const SizedBox(height: 60),
                CircleAvatar(
                  radius: 80, // Increased radius for a larger profile image
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (widget.profileImageUrl.isNotEmpty
                          ? NetworkImage(widget.profileImageUrl)
                          : null),
                  child: _imageFile == null && widget.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 130, right: 130),
                  child: TextButton(
                    onPressed: pickImage,
                    child: const Center(
                      child: Text('Edit image',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ))
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: usernameController, 
                  hintText: 'New username', 
                  obscureText: false
                ),
                const SizedBox(height: 30),
                CustomButton(onTap: saveChanges, name: 'Save')
              ]
            ),
          ),
        )
      )
    );
  }
}