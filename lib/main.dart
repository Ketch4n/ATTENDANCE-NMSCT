import 'package:attendance_nmsct/auth/auth.dart';
import 'package:attendance_nmsct/auth/login.dart';
import 'package:attendance_nmsct/view/admin/index.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isWin = Theme.of(context).platform == TargetPlatform.windows;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance NMSCT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isWin ? const AdminIndex() : const Auth(),
      // home: const Login(),
    );
  }
}
