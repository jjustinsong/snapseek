import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

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
      home: const SearchPage(),
    );
  }
}


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String search = "";

  void changeText(String text) {
    setState(() {
      search = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
        AppBar(
          title: const Center(child: Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(2.0), child: Container(color: Colors.black, height: 0.5))
        ),
      body: Column(
        children: <Widget>[
          SearchBar(changeText),
        ]),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 20),
        child: GNav(
          color: Colors.black,
          activeColor: Colors.black,
          gap: 8,
          padding: EdgeInsets.all(16),
          tabs: [
            GButton(icon: LineIcons.globe),
            GButton(icon: LineIcons.search),
            GButton(icon: LineIcons.user),
          ]
        )),
    );
  }  
}

class SearchBar extends StatefulWidget {
  final Function(String) callback;
  const SearchBar(this.callback, {super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void click(String text) {
    widget.callback(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: controller,
                onSubmitted: (_) => click(controller.text),
              )
            )
          ]
        )
    );
  }
}