// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/auth/auth.dart';
import 'package:attendance_nmsct/auth/login.dart';
import 'package:attendance_nmsct/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future signup(
  BuildContext context,
  String email,
  String password,
  String id,
  String name,
  String roleController,
  DateTime bday,
  String uid,
  String address,
  String section,
  String purpose,
) async {
  String apiUrl = '${Server.host}auth/signup.php';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  final recipient = email;
  final date = DateFormat('yyyy-MM-dd').format(bday.toLocal());
  String jsonData =
      '{"email": "$email", "password": "$password", "fname": "$name", "lname": "$id","uid":"$uid", "bday":"$date","address":"$address","section":"$section","role":"$roleController","purpose":"$purpose"}';
  final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
  final jsonResponse = json.decode(response.body);
  final message = jsonResponse['message'];
  final status = jsonResponse['status'];
  final details = Server.link;

  const subject = "Click the link below to download the Application";

  if (response.statusCode == 200) {
    await sendToAll(context, recipient, details, subject);
    await showAlertDialog(context, status, message);
    // purpose == 'Create'
    //     ?
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
    // : Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => const Auth()));
    // Handle success message as needed
  } else if (response.statusCode == 400) {
    // Email already taken
    await showAlertDialog(context, status, message);
    // Handle email taken message as needed
  } else {
    // Handle other status codes (e.g., 500, 405) as needed
  }
}
