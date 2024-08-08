import 'dart:convert';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';

Future<void> insertAnnouncement(
    BuildContext context, String details, String subject) async {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String apiUrl = '${Server.host}users/student/write_announcement.php';

  // Replace '\n' characters with '<br>' tags for line breaks
  String formattedDetails = details.replaceAll('\n', '<br>');

  // Encode the announcement using jsonEncode
  String jsonData = '{"comment": "$formattedDetails"}';

  try {
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];
      final email = "";

      await sendToAll(
        context,
        email,
        formattedDetails,
        subject,
      ); // Await the email sending
      print("SUCCESS EMAIL");
      showAlertDialog(context, status, message);

      // Handle success message as needed
    } else {
      // Handle other status codes (e.g., 400, 500) as needed+
      final errorMessage =
          'Failed to upload data. Status Code: ${response.statusCode}';
      showAlertDialog(context, 'Error', errorMessage);
    }
  } catch (e) {
    // Handle network or other errors
    final errorMessage = 'Failed to upload data. Error: $e';
    showAlertDialog(context, 'Error', errorMessage);
  }
}

Future<void> sendToAll(
  BuildContext context,
  String emails,
  String announce,
  String subject,
) async {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String url = '${Server.host}db/sendmail.php';
  String body = json.encode({
    'user_emails': emails,
    'announce': announce,
    'subject': subject,
  });

  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Emails sent successfully');
    } else {
      print('Failed to send emails. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending emails: $e');
  }
}
