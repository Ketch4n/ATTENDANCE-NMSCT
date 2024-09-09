import 'package:attendance_nmsct/src/data/firebase/key.dart';
import 'package:firebase_core/firebase_core.dart';

initializeFirebase() async {
  await Firebase.initializeApp(
    // name: "attendance-monitoring",
    options: const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      databaseURL: databaseURL,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
    ),
  );
}
