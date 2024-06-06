import "package:flutter/material.dart";

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 25, right: 25),
      margin: const EdgeInsets.only(left: 25, right: 25),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Sign up",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      )
    );
  }
}