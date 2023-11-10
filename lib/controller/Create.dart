// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future CreateSectEstab(BuildContext context, String code, String pin,
    String loc, String admin_id) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');
  if (userRole == 'Admin') {
    String apiUrl = '${Server.host}users/admin/create.php';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String jsonData =
        '{"code": "$code", "section_name": "$pin",  "admin_id": "$admin_id"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    final jsonResponse = json.decode(response.body);
    final message = jsonResponse['message'];
    final status = jsonResponse['status'];

    if (response.statusCode == 200) {
      await showAlertDialog(context, status, message);

      // Handle success message as needed
    } else if (response.statusCode == 400) {
      // code already taken
      await showAlertDialog(context, status, message);
      // Handle code taken message as needed
    } else {
      // Handle other status codes (e.g., 500, 405) as needed
    }
  } else {
    String apiUrl = '${Server.host}users/establishment/create.php';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String jsonData =
        '{"code": "$code", "establishment_name": "$pin",  "location":"$loc","creator_id": "$admin_id"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    final jsonResponse = json.decode(response.body);
    final message = jsonResponse['message'];
    final status = jsonResponse['status'];

    if (response.statusCode == 200) {
      await showAlertDialog(context, status, message);

      // Handle success message as needed
    } else if (response.statusCode == 400) {
      // code already taken
      await showAlertDialog(context, status, message);
      // Handle code taken message as needed
    } else {
      // Handle other status codes (e.g., 500, 405) as needed
    }
  }
}
