import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:http/http.dart' as http;

Future<void> updateUser(String userID, String status) async {
  String apiUrl = '${Server.host}auth/update_status.php';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'id': userID,
      'status': status,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success']) {
      print('Update successful: ${responseData['message']}');
    } else {
      print('Update failed: ${responseData['message']}');
    }
  } else {
    print('Server error: ${response.statusCode}');
  }
}
