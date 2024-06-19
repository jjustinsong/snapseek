import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String search = "";
  var logger = Logger();
  List<Image> images = [];
  List<String> base64Strings = [];
  bool isLoading = false;

  void changeText(String text) {
    setState(() {
      search = text;
    });
  }

  Future<void> searchImages(String description, int numImages) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/search'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'description': description,
          'numImages': numImages,
        }),
      );

      logger.d('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> base64Strings = jsonDecode(response.body)['images'];
        setState(() {
          this.base64Strings = base64Strings.cast<String>();
          images = this
              .base64Strings
              .map((str) => Image.memory(base64Decode(str)))
              .toList();
        });
      } else {
        logger.e('Error: Server returned ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveImage(String base64) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_images')
            .add({
          'base64': base64,
          'timestamp': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved successfully')),
        );
      } catch (e) {
        logger.e('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  Widget buildImagesGrid() {
    if (isLoading) {
      return Center(child: Text("Loading..."));
    }

    if (images.isEmpty) {
      return Center(
          child: Text(
        "No images to display.",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        String base64 = base64Strings[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: images[index],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => saveImage(base64),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('Search',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          SearchBar(
              onSearch: searchImages,
              onChange: changeText,
              initialText: search),
          const SizedBox(height: 20.0),
          Expanded(
            child: buildImagesGrid(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
  final String initialText;

  const SearchBar({
    required this.onSearch,
    required this.onChange,
    required this.initialText,
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController controller;
  int selectedNumberOfImages = 3;

  List<int> numberOfImagesOptions = [1, 3, 5, 10];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void click() {
    String text = controller.text;
    widget.onSearch(text, selectedNumberOfImages);
    widget.onChange(text);
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
          SizedBox(width: 10), // Spacing
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
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
