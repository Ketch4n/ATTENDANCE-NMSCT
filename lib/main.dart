import 'package:attendance_nmsct/auth/auth.dart';
import 'package:attendance_nmsct/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // name: "attendance-monitoring",
      options: const FirebaseOptions(
    apiKey: "AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE",
    authDomain: "attendance-monitoring-c33b5.firebaseapp.com",
    projectId: "attendance-monitoring-c33b5",
    storageBucket: "attendance-monitoring-c33b5.appspot.com",
    messagingSenderId: "923340212066",
    appId: "1:923340212066:web:cfa048f322dbd305098e3b",
  ));
  setupServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // bool isWin = Theme.of(context).platform == TargetPlatform.windows;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance NMSCT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: isWin ? const AdminIndex() : const Auth(),
      home: const Auth(),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
      // home: const Login(),
    );
  }
}
