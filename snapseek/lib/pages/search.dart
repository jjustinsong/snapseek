import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapseek/pages/feed.dart';
import 'package:snapseek/pages/post.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;
import 'package:path_provider/path_provider.dart';


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

  @override
  void initState() {
    super.initState();
    stream();
  }

  Future<stream_feed.Token> getStreamToken(String firebaseToken, String userId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_stream_token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firebase_token': firebaseToken,
        'user_id': userId,
      })
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('stream_token')) {
        return stream_feed.Token(jsonResponse['stream_token']);
      } else {
        throw Exception('Stream token not found in response');
      }
    } else {
      throw Exception('Failed to load stream token');
    }
  }

  Future<void> stream() async {
    if (firebase.FirebaseAuth.instance.currentUser == null) {
      print("FirebaseAuth user is null");
      return;
    }
    String? firebaseToken = await firebase.FirebaseAuth.instance.currentUser?.getIdToken();
    if (firebaseToken == null) {
      print("Firebase token is null");
      return;
    }
    stream_feed.Token streamToken = await getStreamToken(firebaseToken!, firebase.FirebaseAuth.instance.currentUser!.uid);
    final user = stream_feed.User(id: firebase.FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      try {
        await context.feedClient.setUser(user, streamToken);
      } catch (e) {
        print("Error setting user: $e");
        throw e;
      }
    }
    print("stream");
  }

  Future<void> searchImages(String description, int numImages) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/search'),
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
    firebase.User? user = firebase.FirebaseAuth.instance.currentUser;
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

  Future<String> writeBytesToFile(Uint8List bytes, String fileName) async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      File file = File('${docDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      if (await file.exists()) {
        print("file exists. written to ${file.path}");
        return file.path;
      } else {
        print("file doesn't exist");
        throw Exception('file does not exist');
      }
    } catch (e) {
      print("Error writing file: $e");
      throw e;
    }
  }

  Widget buildImagesGrid() {
    if (isLoading) {
      return const Center(
        child: Text("Loading...",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ));
    }

    if (images.isEmpty) {
      return const Center(
          child: Text(
        "No images to display.",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: images[index],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => saveImage(base64),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => PostPage(base64Image: base64Strings[index])
                        )
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(
                          Icons.post_add,
                          color: Colors.white,
                          size: 24,
                        )
                      )
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () async {
                        final bytes = base64Decode(base64);
                        final filePath = await writeBytesToFile(bytes, 'share_file.png');
                        if (File(filePath).existsSync()) {
                          await Share.shareXFiles([XFile(filePath, mimeType: 'image/png')]);
                        } else {
                          print("File doesn't exist at path: $filePath");
                        }
                        
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        )
                      )
                    )
                  ],
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
                  if (index == 0) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => const FeedPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
                  if (index == 2) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => const ProfilePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
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
