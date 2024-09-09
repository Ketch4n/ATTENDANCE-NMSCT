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
    final userFName = prefs.getString('userFName');
    final userLName = prefs.getString('userLName');
    final userEmail = prefs.getString('userEmail');

    // If user session exists, navigate to Home; otherwise, show Login
    setState(() {
      showLoginScreen = userId == null;
      role = userRole!;
      Session.id = userId!;
      Session.role = userRole;
      Session.fname = userFName!;
      Session.lname = userLName!;
      Session.email = userEmail!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: showLoginScreen
            ? const Login()
            : role == 'Intern'
                ? const StudentHome()
                : const AdministratorHome());
  }
}
