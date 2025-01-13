import 'package:attendance_nmsct/src/auth/login.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/view/administrator/home.dart';
import 'package:attendance_nmsct/src/view/student/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showLoginScreen = true;
  int? role;

  @override
  void initState() {
    super.initState();
    checkUserSession();
  }

  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userRole = prefs.getInt('userRole');
    final userFName = prefs.getString('userFName');
    final userLName = prefs.getString('userLName');
    final userEmail = prefs.getString('userEmail');

    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      showLoginScreen = userId == null;

      if (userId != null && userFName != null && userLName != null) {
        Session.id = userId;
        Session.role = userRole; // userRole can remain nullable if needed
        Session.fname = userFName;
        Session.lname = userLName;
        Session.email = userEmail!; // Can remain nullable if it's optional
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginScreen ? const Login() : const AdministratorHome(),
    );
  }
}
