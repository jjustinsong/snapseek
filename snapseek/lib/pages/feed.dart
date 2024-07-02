import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:snapseek/pages/profile.dart';
import 'package:snapseek/pages/search.dart';
import 'package:snapseek/pages/search_user.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
        ), 
        automaticallyImplyLeading: false,
      ),
      body: TextButton(
        child: Icon(Icons.search),
        onPressed: () {
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchUserPage(),
            )
          );*/
        }
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