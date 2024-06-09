import 'package:flutter/material.dart';

//custom google sign in button widget so that code in login.dart and register.dart files are cleaner

class GoogleButton extends StatelessWidget {
  final String imagePath;
  const GoogleButton({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 192, 192, 192)),
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Center(
          child: Row(
            //centers items in the row
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(imagePath, height: 40),
              ),
              const Text('Google', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))
            ],
          ),
        )
      ),
    );
  }
}