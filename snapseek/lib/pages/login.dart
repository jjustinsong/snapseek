import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:snapseek/components/tile.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUp() {

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text("SnapSeek", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 60),
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
                CustomButton(
                  onTap: signUp,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400]
                      )
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10.0, left: 10.0),
                      child: Text('Or continue with', style: TextStyle(color: Color.fromARGB(255, 99, 98, 98))),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400]
                      )
                    )
                  ]
                ),
                const SizedBox(height: 20.0),
                const Tile(imagePath: 'lib/images/google logo.png'),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Sign in',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                    )
                  ],
                )
              ]
            ),
          )
        )
      )
    );
  }
}