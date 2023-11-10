import 'package:attendance_nmsct/auth/login.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/view/administrator/home.dart';
import 'package:attendance_nmsct/view/student/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showLoginScreen = true;
  String role = "";

  @override
  void initState() {
    super.initState();
    checkUserSession();
  }

  // Check if a user session exists in SharedPreferences
  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userRole = prefs.getString('userRole');
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');

    // If user session exists, navigate to Home; otherwise, show Login
    setState(() {
      showLoginScreen = userId == null;
      role = userRole!;
      Session.id = userId!;
      Session.role = userRole;
      Session.name = userName!;
      Session.email = userEmail!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: showLoginScreen
            ? const Login()
            : role == 'Student'
                ? const StudentHome()
                : const AdministratorHome());
  }
}
