import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapseek/components/button.dart';
import 'package:snapseek/components/textfield.dart';
import 'package:snapseek/components/google_button.dart';

//stateful because we want to show errors on screen for when login credentials are invalid

class Login extends StatefulWidget {

  //parameters for the widget are created here

  final Function()? onTap;
  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //variables used in the widget are created here

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void signIn() async {
    //resets error message to empty every time the button is clicked
    setState(() {
      errorMessage = '';
    });
    //loading circle
    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
    try {
      //firebase sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        //get text values from controllers
        email: emailController.text,
        password: passwordController.text,
      );
      //turn off loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      //set error message if we run into error
      setState(() {
        errorMessage = 'Incorrect email/password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      //singlechildscrollview used to prevent screen overflow when keyboard is opened
      body: SingleChildScrollView(
        //safearea used to prevent widgets from showing up in areas such as iphone 14 top left and right corners
        child: SafeArea(
          //centers all widgets
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                //centers items in the column
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
                  //sizedbox used for creating spaces between widgets, can also use padding but this is convenient
                  const SizedBox(height: 10.0),
                  //if error message is not an empty string, show the message in red
                  if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10.0),
                  const Text('Forgot password?', style: TextStyle(color: Color.fromARGB(255, 99, 98, 98))),
                  const SizedBox(height: 10.0),
                  CustomButton(
                    onTap: signIn,
                    name: 'Sign in'
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      //expands a child of the row so that it fills all available space
                      Expanded(
                        //creates line
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
                  const GoogleButton(imagePath: 'lib/images/google logo.png'),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account yet?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      //gesture detector to make text a button
                      GestureDetector(
                        //onTap passed in from login_or_register.dart file
                        //to call variables from the stateful class, use 'widget._____'
                        onTap: widget.onTap,
                        child: const Text(
                          'Sign up',
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