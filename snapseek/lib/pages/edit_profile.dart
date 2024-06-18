import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  Future<void> saveChanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'username': usernameController.text});
    await user.updatePhotoURL(widget.profileImageUrl);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage()
      )
    );
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
                  backgroundImage: widget.profileImageUrl.isNotEmpty
                      ? NetworkImage(widget.profileImageUrl)
                      : null,
                  child: widget.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 110, right: 110),
                  child: TextButton(
                    onPressed: () {
                              
                    },
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