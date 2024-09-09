import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';

Future removeClassRoom(
  context,
  String id,
  String path,
) async {
  final ref = path == 'room' ? 'establishment' : 'section';
  const stat = 'In-Active';
  print("ID : $id");
  String apiUrl = '${Server.host}users/admin/remove.php';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String jsonData = '{"id": "$id","ref":"$ref","status":"$stat"}';
  final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
  final jsonResponse = json.decode(response.body);
  final status = jsonResponse['status'];
  final message = jsonResponse['message'];

  if (response.statusCode == 200) {
    showAlertDialog(context, status, message);
  } else {
    print('Failed to update database. Error: ${response.statusCode}');
  }
}
