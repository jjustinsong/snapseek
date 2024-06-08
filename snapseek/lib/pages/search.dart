import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


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

  var logger = Logger();

  Future<void> searchImages(String description) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/search'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'description': description,
        })
      );
      logger.i('Response status: ${response.statusCode}');
    } catch(e) {
      // ignore: avoid_print
      logger.e('Error: $e');
    }
  }

  void buttonHandler() {

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
          SearchBar(onSearch: searchImages, onChange: changeText),
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
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: controller,
                onSubmitted: (_) => click(),
              )
            )
          ]
        )
    );
  }
}