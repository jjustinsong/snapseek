import 'package:flutter/material.dart';

//custom text field widget so that code in login.dart and register.dart files are cleaner

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  
  //controllers used to track what is typed in textfields
  //hinttext is what shows in the textbox before you type anything
  //obscure text for passwords so that it isn't shown when typing

  const CustomTextField({
    super.key, 
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 192, 192, 192)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500])
        )
      )
    );
  }
}