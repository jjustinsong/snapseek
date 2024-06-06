import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 90.0),
                child: Text("SnapSeek", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))
              ),
              const Padding(
                padding: EdgeInsets.only(top: 110),
                child: Text("Create an account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 30.0),
                child: Text("Enter your email to sign up for SnapSeek", style: TextStyle(fontSize: 15))
              ),
              CustomTextField(
                controller: usernameController,
                hintText: 'Email address',
                obscureText: false,
              ),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              Text("Forgot Password?", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 30.0),
              CustomButton(),
            ]
          )
        )
      )
    );
  }
}