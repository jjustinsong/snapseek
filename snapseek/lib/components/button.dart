import "package:flutter/material.dart";

class CustomButton extends StatelessWidget {

  final Function()? onTap;
  final String name;

  //pass in name variable to use as the button's label

  const CustomButton({super.key, required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    //gesture detector to turn container into a button, easier to format containers
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        )
      ),
    );
  }
}