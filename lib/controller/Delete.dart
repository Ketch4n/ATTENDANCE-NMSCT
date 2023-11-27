import 'dart:convert';
import 'package:attendance_nmsct/widgets/accomplishment_alert.dart';
import 'package:http/http.dart' as http;

import 'package:attendance_nmsct/data/server.dart';

Future deleteAccomplishment(context, String id) async {
  String apiUrl = '${Server.host}users/student/accomplishment_delete.php';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String jsonData = '{"id": "$id"}';
  final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
  final jsonResponse = json.decode(response.body);
  final status = jsonResponse['status'];
  final message = jsonResponse['message'];

  if (response.statusCode == 200) {
    await accAlertDialog(context, status, message);
  } else {
    print('Failed to update database. Error: ${response.statusCode}');
  }
}
