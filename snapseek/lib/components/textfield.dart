import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  
  const CustomTextField({
    super.key, 
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 25, right: 25),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 192, 192, 192)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180))
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