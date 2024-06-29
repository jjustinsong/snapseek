import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

class StreamService {
  late final StreamFeedClient client;

  StreamService() {
    client = StreamFeedClient('wknqxgxtxyyu');
  }

  Future<void> setUser(String userId, Token userToken) async {
    try {
      await client.setUser(
        User(id: userId),
        userToken,
      );
      print("Success");
    } catch (e) {
      print("Error: $e");
    }
  }
}