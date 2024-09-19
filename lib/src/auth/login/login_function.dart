// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/face_recognition/pages/home.dart';
import 'package:attendance_nmsct/src/firebase/server.dart';

import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future login(BuildContext context, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    String title = "Please Input Data";
    String message = "Username or Password Empty !";
    await showAlertDialog(context, title, message);
  } else {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}auth/user_login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        final message = data['message'];

        final userId = data['id'];
        final userRole = data['role'];
        final userStatus = data['status'];

        final userFName = data['fname'];
        final userLName = data['lname'];
        final userEmail = data['email'];

        final userCourse = data['course'];
        final userBday = data['bday'];
        final userAddress = data['address'];

        if (data['success']) {
          final prefs = await SharedPreferences.getInstance();

          prefs.setInt('uID', userId);
          prefs.setInt('uROLE', userRole);
          prefs.setInt('uSTATUS', userStatus);

          prefs.setString('uFNAME', userFName);
          prefs.setString('uLNAME', userLName);
          prefs.setString('uEMAIL', userEmail);

          prefs.setString('uCOURSE', userCourse);
          prefs.setString('uBDAY', userBday);
          prefs.setString('uADDRESS', userAddress);

          const title = "Login success";
          String content = "Welcome $message";

          await showAlertDialog(context, title, content);
          userRole == 1
              ? Navigator.pushNamedAndRemoveUntil(
                  context,
                  'student/index',
                  (route) => false,
                )
              : userRole == 0
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceLauncherPage(
                          purpose: 'signup',
                          refreshCallback: () {},
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Duck(),
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
      const title = "Network Error";
      await showAlertDialog(context, title, 'Error: $error');
    }
  }
}
