import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:snapseek/components/tile.dart';

class Register extends StatefulWidget {

  final Function()? onTap;
  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void signUp() async {
    setState(() {
      errorMessage = '';
    });
    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        errorMessage = 'Incorrect email/password';
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
                  const Text('Create an account', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
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
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Confirm password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  CustomButton(
                    onTap: signUp,
                    name: 'Sign up'
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
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Sign in',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                        ),
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