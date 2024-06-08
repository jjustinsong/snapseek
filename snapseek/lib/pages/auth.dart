import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapseek/pages/login.dart';
import 'package:snapseek/pages/search.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const SearchPage();
          }
          else {
            return Login();
          }
        }
      ),
    );
  }
}