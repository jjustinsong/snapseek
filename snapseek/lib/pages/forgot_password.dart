import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  String message = ''; // Used to display feedback messages

  void resetPassword() async {
    // Check if the email text is empty
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      setState(() {
        message = "Please enter a valid email address.";
      });
      return; // Stop the function if validation fails
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        message = "Password reset link sent! Check your email.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trouble Logging In?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding:
                    EdgeInsets.all(16.0), // Adjust the padding value as needed
                child: Text(
                  "Enter your email and we'll send you a link to get back into your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16), // Optional: Adjust font size as needed
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                hintText: "Email address",
                obscureText: false,
              ),
              const SizedBox(height: 20),
              if (message.isNotEmpty)
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 14, 105, 224))),
              const SizedBox(height: 20),
              CustomButton(onTap: resetPassword, name: 'Send Login Link'),
            ],
          ),
        ),
      ),
    );
  }
}
