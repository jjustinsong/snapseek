import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapseek/pages/searchpage.dart';
import 'package:snapseek/pages/login.dart';

void main() {
  runApp(const SnapSeek());
}

class SnapSeek extends StatelessWidget {
  const SnapSeek({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSeek',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpPage(),
    );
  }
}