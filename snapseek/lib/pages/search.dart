import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:snapseek/pages/gallery.dart';
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

  Future<void> searchImages(String description, int numImages) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/search'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'description': description,
          'numImages': numImages, // Pass the number of images to your backend
        }),
      );
      logger.i('Response status: ${response.statusCode}');
      // Handle the response if needed
    } catch (e) {
      logger.e('Error: $e');
    }
  }

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
      ),
      body: Column(children: <Widget>[
        SearchBar(onSearch: searchImages, onChange: changeText),
        const SizedBox(height: 20.0),
        const Gallery(),
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
  final Function(String, int) onSearch;
  final Function(String) onChange;

  const SearchBar({
    required this.onSearch,
    required this.onChange,
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();
  int selectedNumberOfImages = 3; // Default number of images

  List<int> numberOfImagesOptions = [1, 3, 5, 10]; // Options for the dropdown

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void click() {
    String text = controller.text;
    widget.onSearch(text, selectedNumberOfImages);
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
            ),
          ),
          SizedBox(
              width:
                  10), // Provides spacing between the search bar and the dropdown
          DropdownButton<int>(
            value: selectedNumberOfImages,
            icon: Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: TextStyle(color: Theme.of(context).primaryColor),
            underline: Container(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedNumberOfImages = newValue;
                });
              }
            },
            items:
                numberOfImagesOptions.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value
                    .toString()), // Changed here to display only the number
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
