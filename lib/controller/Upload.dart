// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/view.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime now = DateTime.now();
final date = DateFormat('yyyy-MM-dd').format(now.toLocal());

Future uploadAccomplishment(BuildContext context, ids, comment) async {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String apiUrl = '${Server.host}users/student/upload.php';

  // Encode the comment using jsonEncode
  String encodedComment = jsonEncode(comment);

  String jsonData =
      '{"email": "${Session.email}", "section": "$ids", "comment": $encodedComment, "date": "$date"}';

  try {
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];

      showAlertDialog(context, status, message);

      // Handle success message as needed
    } else {
      // Handle other status codes (e.g., 400, 500) as needed
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
