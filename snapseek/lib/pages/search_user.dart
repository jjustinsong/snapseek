/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;


class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  String search = "";

  void changeText(String text) {
    setState(() {
      search = text;
    });
  }

  void onSearch(String s, int i) {

  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .map((doc) => {
          'id': doc.id,
          'username': doc['username'],
          'profileImageUrl': doc.data()['profileImageUrl']
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          SearchBar(
            onChange: changeText,
            onSearch: onSearch,
            initialText: search,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                }
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (ctx, index) {
                    return UserTile(
                      user: stream_feed.User(id: users[index]['id'], data: users[index]),
                      onTap: () {},
                      trailing: Text(users[index]['username'])
                    );
                  }
                );
              }
            ),
          ),
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

  Future<Map<String, String>> fetchUserData(String userId) async {
    DocumentSnapshot userDoc = await 
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(fetchProfilePicture() as String)),
      title: Text(fetchUsername() as String),
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
      child: Expanded(
        child: CupertinoSearchTextField(
          controller: controller,
          onSubmitted: (_) => click(),
        ),
      ),
    );
  }
}*/