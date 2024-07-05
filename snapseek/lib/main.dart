import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:snapseek/pages/auth.dart';
import 'package:snapseek/pages/search.dart';
import 'package:snapseek/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import 'package:flutter/rendering.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const apiKey = 'wknqxgxtxyyu';
  final client = StreamFeedClient(apiKey);
  // Disable all debug paints
  debugPaintSizeEnabled = false;
  debugPaintPointersEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugRepaintRainbowEnabled = false;
  runApp(SnapSeek(client: client));
}

class SnapSeek extends StatelessWidget {
  final StreamFeedClient client;
  const SnapSeek({super.key, required this.client});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSeek',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => FeedProvider(
        bloc: FeedBloc(
          client: client,
        ),
        child: child!,
      ),
      home: const Auth(),
    );
  }
}
