import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/ClassModel.dart';
import 'package:http/http.dart' as http;

Future<void> fetchClassmates(classmateStreamController, id) async {
  final response = await http.post(
    Uri.parse('${Server.host}users/student/class.php'),
    body: {'section_id': id},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<ClassModel> classmates = data
        .map((classmateData) => ClassModel.fromJson(classmateData))
        .toList();

    Admin.id = classmates[0].admin_id;
    Admin.name = classmates[0].admin_name;
    Admin.email = classmates[0].admin_email;

    // Add the list of classmates to the stream
    classmateStreamController.add(classmates);
  } else {
    throw Exception('Failed to load data');
  }
}
