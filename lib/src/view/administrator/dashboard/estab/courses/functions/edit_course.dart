import 'dart:convert';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:http/http.dart' as http;

Future<void> editCourse(String courseID, String courseName) async {
  final String apiUrl = "${Server.host}/users/establishment/edit_course.php";

  final Map<String, String> requestBody = {
    'course_id': courseID,
    'course_name': courseName.toUpperCase(),
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Course updated successfully!');
    } else {
      print('Failed to add course: ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
