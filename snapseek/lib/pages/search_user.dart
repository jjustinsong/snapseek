import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;
import 'package:http/http.dart' as http;
import 'dart:convert';


class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  String search = "";
  List<stream_feed.User> allUsers = [];
  List<stream_feed.User> filteredUsers = [];

  void changeText(String text) {
    setState(() {
      search = text;
      filteredUsers = allUsers.where((user) {
        return (user.data?['username'] as String).toLowerCase().contains(search.toLowerCase());
      }).toList();
    });
  }

  void onSearch(String s, int i) {

  }

  @override
  void initState() {
    super.initState();
    stream();
    fetchUserData().then((users) {
      setState(() {
        allUsers = users;
        filteredUsers = users;
      });
    });
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

  Future<List<stream_feed.User>> fetchUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    String currentUserId = firebase.FirebaseAuth.instance.currentUser?.uid ?? '';
    return snapshot.docs.where((doc) => doc.id != currentUserId).map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return stream_feed.User(
        id: doc.id,
        data: {
          'username': data['username'] as String,
          'profileImageUrl': data.containsKey('profileImageUrl') ? data['profileImageUrl'] as String : '',
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
      body: Column(
        children: [
          SearchBar(
            onChange: changeText,
            onSearch: onSearch,
            initialText: search,
          ),
          Expanded(
            child: ListView(
              children: filteredUsers.map((user) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FollowUserTile(user: user),
                );
              }).toList()
            )
          )
        ],
      )
    );
  }
}

class FollowUserTile extends StatefulWidget {
  const FollowUserTile({
    super.key,
    required this.user,
  });

  final stream_feed.User user;

  @override
  State<FollowUserTile> createState() => _FollowUserTileState();
}

class _FollowUserTileState extends State<FollowUserTile> {
  bool _isFollowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final result =
        await context.feedBloc.isFollowingFeed(followerId: widget.user.id!);
    _setStateFollowing(result);
  }

  Future<void> follow() async {
    try {
      _setStateFollowing(true);
      await context.feedBloc.followFeed(followeeId: widget.user.id!);
    } on Exception catch (e, st) {
      _setStateFollowing(false);
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> unfollow() async {
    try {
      _setStateFollowing(false);
      await context.feedBloc.unfollowFeed(unfolloweeId: widget.user.id!);
    } on Exception catch (e, st) {
      _setStateFollowing(true);
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  void _setStateFollowing(bool following) {
    setState(() {
      _isFollowing = following;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserTile(
      user: widget.user,
      trailing: TextButton(
        onPressed: () {
          if (_isFollowing) {
            unfollow();
          } else {
            follow();
          }
        },
        child: _isFollowing ? const Text('unfollow') : const Text('follow'),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    Key? key,
    required this.user,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  final stream_feed.User user;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    String profileImageUrl = user.data?['profileImageUrl'] as String? ?? '';
    String username = user.data?['username'] as String? ?? '';

    ImageProvider imageProvider;
    if (profileImageUrl.isNotEmpty && Uri.parse(profileImageUrl).isAbsolute) {
      imageProvider = NetworkImage(profileImageUrl);
    } else {
      imageProvider = const AssetImage('lib/images/default_avatar.jpeg');
    }
    return ListTile(
      leading: CircleAvatar(backgroundImage: imageProvider),
      title: Text(username),
      onTap: onTap,
      trailing: trailing,
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
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSearchTextField(
        controller: controller,
        onSubmitted: (_) => click(),
      ),
    );
  }
}