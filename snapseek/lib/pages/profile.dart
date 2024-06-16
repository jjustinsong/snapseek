import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:snapseek/pages/search.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading..."; // Initial text
  String profileImageUrl = ""; // URL for profile image, if available

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  //firebase sign out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  
  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] as String;
        });
      } else {
        setState(() {
          username = "No username found";
        });
      }
    } else {
      setState(() {
        username = "User not logged in";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
            color: Colors.black,
          ),
        ]
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 60, // Increased radius for a larger profile image
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              print("Edit button tapped");
                            },
                            child: const Text("Edit", style: TextStyle(fontSize: 16)),
                          ),
                          const Text(" • ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              print("Share button tapped");
                            },
                            child:
                                const Text("Share", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    print("Feed button tapped");
                  },
                  child: const Text("Gallery",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                const SizedBox(width: 20), // Spacing between buttons
                TextButton(
                  onPressed: () {
                    print("Gallery button tapped");
                  },
                  child: const Text("Feed",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
          ),
          Expanded(
            // This will make the GridView take up all remaining space
            child: GridView.count(
              crossAxisCount: 2, // Number of columns in the grid
              childAspectRatio: 1.0, // Aspect ratio of each cell
              crossAxisSpacing: 10, // Spacing between the columns
              mainAxisSpacing: 10, // Spacing between the rows
              padding: const EdgeInsets.all(16), // Padding around the grid
              children: List.generate(6, (index) {
                // Generate 4 empty boxes
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300], // Light grey color for the boxes
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      border: Border.all(
                          color: Colors.grey[400]!) // Border around each box
                      ),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
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
