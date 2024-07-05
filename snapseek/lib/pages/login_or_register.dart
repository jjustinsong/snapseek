/*import 'package:flutter/material.dart';
import 'package:snapseek/pages/login.dart';
import 'package:snapseek/pages/register.dart';

//toggle to show login or register pages

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLogin = true;

  //passed into the Login and Register pages as the onTap function
  //toggling shows either the login page or the register page
  void togglePages() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return Login(
        onTap: togglePages
      );
    } else {
      return Register(
        onTap: togglePages
      );
    }
  }
}*/