import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_database/firebase_database.dart';

class KeyAPI {
  static String code = "AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE";
}

class Server {
  static String host = "";
  static String api = "";
  static String id = "";

  static void fetchHostFromDatabase() {
    DatabaseReference hostRef = FirebaseDatabase.instance.ref().child('server');

    hostRef.onValue.listen((event) {
      // Update the host value when it changes in the database
      host = (event.snapshot.value as String) ?? ''; // Specify type explicitly
    });
  }

  static void fetchApiFromDatabase() {
    DatabaseReference apiRef = FirebaseDatabase.instance.ref().child('doc_api');

    apiRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        api = event.snapshot.value as String? ?? "";
      } else {
        api = "";
      }
    }, onError: (error) {
      print("Error fetching API: $error");
    });
  }

  static void fetchIdFromDatabase() {
    DatabaseReference idRef = FirebaseDatabase.instance.ref().child('doc_id');

    idRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        id = event.snapshot.value as String? ?? "";
      } else {
        id = "";
      }
    }, onError: (error) {
      print("Error fetching ID: $error");
    });
  }
}
