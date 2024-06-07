import "package:flutter/material.dart";

class CustomButton extends StatelessWidget {

  final Function()? onTap;

  const CustomButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Sign up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        )
      ),
    );
  }
}