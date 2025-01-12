// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/storage/shared_preference.dart';
import 'package:attendance_nmsct/src/view/administrator/home.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> login(
    BuildContext context, String email, String password, int role) async {
  if (email.isEmpty || password.isEmpty) {
    await showAlertDialog(
      context,
      "Please Input Data",
      "Username or Password is empty!",
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('${Server.host}auth/super_login.php'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success'] == true) {
        await saveUserDataToPreferences(data);
        await showAlertDialog(
          context,
          "Login Successful",
          "Welcome ${data['message']}",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdministratorHome()),
        );
      } else {
        await showAlertDialog(context, "Login Failed", data['message']);
      }
    } else {
      await showAlertDialog(
        context,
        "Failed to Log In",
        "HTTP Status Code: ${response.statusCode}",
      );
    }
  } catch (error) {
    await showAlertDialog(
      context,
      "Network Error",
      "Error: $error",
    );
  }
}
