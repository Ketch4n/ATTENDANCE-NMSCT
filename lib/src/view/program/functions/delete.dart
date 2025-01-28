import 'dart:convert';
import 'package:attendance_nmsct/src/components/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';

Future deleteProgram(context, int id) async {
  String apiUrl =
      '${Server.host}users/establishment/program/delete_program.php';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String jsonData = json.encode({'id': id});

  final response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // final status = jsonResponse['status'];
    final message = jsonResponse['message'];
    customSnackBar(context, 0, message);
  } else {
    print('Failed to delete program. Error: ${response.statusCode}');
  }
}
