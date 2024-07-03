import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:snapseek/components/listactivityitem.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:snapseek/pages/search.dart';
import 'package:snapseek/pages/search_user.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart' as stream_feed;
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final stream_feed.EnrichmentFlags _flags = stream_feed.EnrichmentFlags()
      ..withReactionCounts()
      ..withOwnReactions();
  
  bool _isPaginating = false;

  static const _feedGroup = 'timeline';

  Future<void> _loadMore() async {
    // Ensure we're not already loading more activities.
    if (!_isPaginating) {
      _isPaginating = true;
      context.feedBloc
          .loadMoreEnrichedActivities(feedGroup: _feedGroup, flags: _flags)
          .whenComplete(() {
        _isPaginating = false;
      });
    }
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

  @override
  void initState() {
    super.initState();
    stream();
  }

  @override
  Widget build(BuildContext context) {
    final client = context.feedClient;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
        ), 
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TextButton(
            child: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUserPage(),
                )
              );
            }
          ),
          Expanded(
            child: stream_feed.FlatFeedCore(
              feedGroup: _feedGroup,
              emptyBuilder: (context) => const Center(
                child: Text('No posts', style: TextStyle(fontSize: 18, color: Colors.grey))
              ),
              userId: client.currentUser!.id,
              limit: 10,
              flags: _flags,
              errorBuilder: (context, error) => const Center(
                child: Text('Error')
              ),
              loadingBuilder: (context) => const Center(
                child: CircularProgressIndicator()
              ),
              feedBuilder: (
                BuildContext context,
                activities
              ) {
                return RefreshIndicator(
                  onRefresh: () {
                    return context.feedBloc.refreshPaginatedEnrichedActivities(
                      feedGroup: _feedGroup,
                      flags: _flags,
                    );
                  },
                  child: ListView.separated(
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      bool shouldLoadMore = activities.length - 3 == index;
                      if (shouldLoadMore) {
                        _loadMore();
                      }
                      return ListActivityItem(
                        activity: activities[index],
                        feedGroup: _feedGroup,
                      );
                    }
                  )
                );
              }
            ),
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
                  if (index == 1) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => const SearchPage(),
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