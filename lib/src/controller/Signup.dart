import 'dart:convert';
import 'package:attendance_nmsct/src/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';

String apiUrl = '${Server.host}auth/signup.php';
const Map<String, String> headers = {'Content-Type': 'application/json'};
const String webLink = "https://attendance-monitoring-c33b5.web.app/";

Future<void> signup(
  BuildContext context,
  String email,
  String password,
  String id,
  String name,
  String roleController,
  String id_number,
  String course,
  String contact_number,
  String section,
  String semester,
  String schoolYear,
  String faculty,
  String purpose,
) async {
  final recipient = email;
  final jsonData = jsonEncode({
    'email': email,
    'password': password,
    'fname': name,
    'lname': id,
    'course': course,
    'id_number': id_number,
    'contact_number': contact_number,
    'section': section,
    'semester': semester,
    'schoolYear': schoolYear,
    'faculty_email': faculty,
    'role': roleController,
    'purpose': purpose,
  });

  try {
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];
      await handleSuccess(
          context, recipient, email, password, purpose, status, message);
    } else {
      await handleError(context, response);
    }
  } catch (e) {
    print('An error occurred: $e');
    await showAlertDialog(
        context, 'Error', 'An error occurred while processing your request.');
  }
}

Future<void> handleSuccess(
  BuildContext context,
  String recipient,
  String email,
  String password,
  String purpose,
  String status,
  String message,
) async {
  final link = Server.link.toString();
  String details;
  String subject =
      purpose == 'INTERN' ? "Download the App" : "$purpose Invitation";

  if (purpose == 'INTERN') {
    details =
        "Click the link below to download the Application\nComplete your account by registering facial recognition<br><a href='$link'>Download</a>";
  } else if (purpose == 'NMSCST' || purpose == 'FACULTY') {
    details =
        "You are invited as $purpose\nPlease click the link:\n<a href='$webLink'>link</a>\n\nThis is your account access:\nEmail: $email\nPassword: $password\n";
  } else {
    await showAlertDialog(context, status, message);
    return;
  }

  showAlertDialog(context, status, message);
  await sendToAll(context, recipient, details, subject);
}

Future<void> handleError(BuildContext context, http.Response response) async {
  final jsonResponse = json.decode(response.body);
  final message = jsonResponse['message'];
  final status = jsonResponse['status'];

  if (response.statusCode == 400) {
    await showAlertDialog(context, status, message);
  } else {
    await showAlertDialog(context, 'Error',
        'An unexpected error occurred. Please try again later.');
  }
}
