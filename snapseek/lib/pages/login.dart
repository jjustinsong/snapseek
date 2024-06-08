import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:snapseek/components/tile.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage ='';

  void signIn() async {
    try {
      showDialog(context: context, builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No account found under email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 100.0, bottom: 40.0),
                    child: Text("SnapSeek", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email address',
                    obscureText: false,
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10.0),
                  if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10.0),
                  const Text('Forgot password?', style: TextStyle(color: Color.fromARGB(255, 99, 98, 98))),
                  const SizedBox(height: 20.0),
                  CustomButton(
                    onTap: signIn,
                    name: 'Sign in'
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
                        "Don't have an account yet?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                      )
                    ],
                  )
                ]
              ),
            )
          )
        ),
      )
    );
  }
}