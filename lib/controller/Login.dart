// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/auth/server.dart';
import 'package:attendance_nmsct/auth/session.dart';
import 'package:attendance_nmsct/view/establishment/home.dart';
import 'package:attendance_nmsct/view/student/home.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Make sure you import your server configuration

Future login(
  BuildContext context,
  String email,
  String password,
) async {
  if (email.isEmpty || password.isEmpty) {
    String title = "Please Input Data";
    String message = "Username or Password Empty !";

    await showAlertDialog(context, title, message);
  } else {
    try {
      // HTTP request
      final response = await http.post(
        Uri.parse('${Server.host}auth/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      Map<String, dynamic> data = json.decode(response.body);
      final message = data['message'];
      final userId = data['id'];
      final userRole = data['role'];
      // final status = "${response.statusCode}";

      if (response.statusCode == 200) {
        if (data['success']) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', userId);
          prefs.setString('userRole', userRole);

          Session.id = userId;
          Session.role = userRole;

          const title = "Login success";
          String content = "Welcome $message";

          await showAlertDialog(context, title, content);
          userRole == 'Student'
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentHome(),
                  ),
                )
              : Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EstabHome(),
                  ),
                );
        } else {
          const title = "Login failed";
          await showAlertDialog(context, title, message);
        }
      } else {
        const title = "Failed to log in";

        await showAlertDialog(
            context, title, 'HTTP Status Code: ${response.statusCode}');
      }
    } catch (error) {
      const title = "Failed to log in";
      await showAlertDialog(context, title, 'Error: $error');
    }
  }
}
