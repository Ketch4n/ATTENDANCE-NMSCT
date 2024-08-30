import 'package:attendance_nmsct/src/auth/login/login_page.dart';
import 'package:attendance_nmsct/src/pages/student/student_index.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showLoginScreen = true;
  int role = 2;

  @override
  void initState() {
    super.initState();
    checkUserSession();
  }

  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('uID');
    final userRole = prefs.getInt('uROLE');

    setState(() {
      showLoginScreen = userId == null;
      role = userRole!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginScreen
          ? const LoginPage()
          : role == 2
              ? const StudentIndex()
              : const LoginPage(),
    );
  }
}
