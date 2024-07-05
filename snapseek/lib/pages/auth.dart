import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:snapseek/pages/login.dart';
import 'package:snapseek/pages/login_or_register.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:snapseek/pages/register.dart';
import 'package:snapseek/pages/search.dart';

//determines which page to actually show on app launch; if logged in: search page, if logged out: login or register page

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool _isRegisterComplete = false;

  void onRegisterComplete() {
    setState(() {
      _isRegisterComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && _isRegisterComplete) {
            return const SearchPage();
          } else {
            return Register(onRegisterComplete: onRegisterComplete);
          }
        }
      ),
    );
  }
}