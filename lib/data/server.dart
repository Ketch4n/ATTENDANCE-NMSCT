import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_database/firebase_database.dart';

class Server {
  static String host = "";
  static String link = "";

  static void fetchHostFromDatabase() {
    DatabaseReference hostRef =
        FirebaseDatabase.instance.reference().child('server');

    hostRef.onValue.listen((event) {
      // Update the host value when it changes in the database
      host = (event.snapshot.value as String) ?? ''; // Specify type explicitly
    });
  }

  static void fetchLinkFromDatabase() {
    DatabaseReference linkref =
        FirebaseDatabase.instance.reference().child('link');

    linkref.onValue.listen((event) {
      link = (event.snapshot.value as String) ?? '';
    });
  }
}

class KeyAPI {
  static String code = "AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE";
}
