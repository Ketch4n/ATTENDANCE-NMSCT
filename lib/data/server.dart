import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class Server {
  static String host = '';
  static String link = '';

  // This will hold the stream subscription to manage it properly
  static late StreamSubscription<DatabaseEvent> _hostSubscription;
  static late StreamSubscription<DatabaseEvent> _linkSubscription;

  static void fetchHostFromDatabase() {
    final DatabaseReference hostRef =
        FirebaseDatabase.instance.ref().child('server');

    _hostSubscription = hostRef.onValue.listen(
      (event) {
        try {
          host = event.snapshot.value as String? ?? '';
        } catch (e) {
          print('Error fetching host: $e');
        }
      },
      onError: (error) {
        print('Error listening to host changes: $error');
      },
    );
  }

  static void fetchLinkFromDatabase() {
    final DatabaseReference linkRef =
        FirebaseDatabase.instance.ref().child('link');

    _linkSubscription = linkRef.onValue.listen(
      (event) {
        try {
          link = event.snapshot.value as String? ?? '';
        } catch (e) {
          print('Error fetching link: $e');
        }
      },
      onError: (error) {
        print('Error listening to link changes: $error');
      },
    );
  }

  // Call this method to stop listening to the streams and clean up resources
  static void dispose() {
    _hostSubscription.cancel();
    _linkSubscription.cancel();
  }
}

class KeyAPI {
  static String code = "AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE";
}
