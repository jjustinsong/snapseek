import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapseek/pages/profile.dart';

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
      if (usernameController.text.isNotEmpty) {
        await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'username': usernameController.text});
      }
      print(_imageFile);
      if (_imageFile != null) {
        String imageUrl = await uploadImage(_imageFile!);
        await user!.updatePhotoURL(imageUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profileImageUrl': imageUrl});
      }
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