import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:snapseek/pages/profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //variable to keep track of text that is being typed in the search bar
  String search = "";

  void changeText(String text) {
    setState(() {
      search = text;
    });
  }

  var logger = Logger();

  //firebase sign out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  //api call; doesn't work
  Future<void> searchImages(String description) async {
    try {
      final response = await http.post(Uri.parse('http://10.0.2.2:5000/search'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'description': description,
          }));
      logger.i('Response status: ${response.statusCode}');
    } catch (e) {
      // ignore: avoid_print
      logger.e('Error: $e');
    }
  }

  void buttonHandler() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('Search',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: Colors.black, height: 0.5)),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
            color: Colors.black,
          ),
        ],
      ),
      body: Column(children: <Widget>[
        SearchBar(onSearch: searchImages, onChange: changeText),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: GNav(
                color: Colors.black,
                activeColor: Colors.black,
                onTabChange: (index) {
                  if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  }
                },
                tabs: const [
                  GButton(icon: LineIcons.globe),
                  GButton(icon: LineIcons.search),
                  GButton(icon: LineIcons.user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  //parameters for widget constructor
  //onSearch for post request
  //onChange to actively show what is being typed on the search bar
  final Function(String) onSearch;
  final Function(String) onChange;
  const SearchBar({required this.onSearch, required this.onChange, super.key});

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

  void click() {
    String text = controller.text;
    widget.onSearch(text);
    widget.onChange(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(children: [
          Expanded(
              child: CupertinoSearchTextField(
            controller: controller,
            //executes when keyboard 'return' or 'search' button is clicked
            onSubmitted: (_) => click(),
          ))
        ]));
  }
}
