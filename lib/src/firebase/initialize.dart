import 'package:attendance_nmsct/data/server.dart';
import 'package:firebase_core/firebase_core.dart';

initializeFirebase() {
  return Firebase.initializeApp(
    // name: "attendance-monitoring",
    options: FirebaseOptions(
      apiKey: KeyAPI.code,
      authDomain: "attendance-monitoring-c33b5.firebaseapp.com",
      projectId: "attendance-monitoring-c33b5",
      databaseURL:
          'https://attendance-monitoring-c33b5-default-rtdb.firebaseio.com/',
      storageBucket: "attendance-monitoring-c33b5.appspot.com",
      messagingSenderId: "923340212066",
      appId: "1:923340212066:web:cfa048f322dbd305098e3b",
    ),
  );
}
