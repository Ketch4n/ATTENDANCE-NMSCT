import 'dart:convert';

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> joinClassRoom(
    BuildContext context, String path, String ref, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString('userId');
  final sub = ref == 'room' ? 'establishment_id' : 'section_id';
  String apiUrl = '${Server.host}users/student/join.php';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String jsonData =
      '{"id": "$id", "path": "$path","ref":"$ref", "sub":"$sub","code":"$pin"}';
  final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
  final jsonResponse = json.decode(response.body);
  final status = jsonResponse['status'];
  final message = jsonResponse['message'];

  if (response.statusCode == 200) {
    await showAlertDialog(context, status, message);
  } else {
    print('Failed to update database. Error: ${response.statusCode}');
  }
}
