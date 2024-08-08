import 'dart:convert';
import 'package:attendance_nmsct/auth/login.dart';
import 'package:attendance_nmsct/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:attendance_nmsct/data/server.dart';

Future<void> signup(
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
      '{"email": "$email", "password": "$password", "fname": "$name", "lname": "$id", "uid":"$uid", "bday":"$date", "address":"$address", "section":"$section", "role":"$roleController", "purpose":"$purpose"}';

  try {
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];
      final link = Server.link.toString();

      final details =
          "Click the link below to download the Application\nComplete your account by registering facial recognition<br><a href='$link'>Download</a>";
      const subject = "Download the App";

      await sendToAll(context, recipient, details, subject);

      await showAlertDialog(context, status, message);

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Login()),
      // );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else if (response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];

      await showAlertDialog(context, status, message);
    } else {
      // Handle other status codes (e.g., 500, 405)
      await showAlertDialog(context, 'Error',
          'An unexpected error occurred. Please try again later.');
    }
  } catch (e) {
    // Handle any errors from the HTTP request
    print('An error occurred: $e');
    await showAlertDialog(
        context, 'Error', 'An error occurred while processing your request.');
  }
}
