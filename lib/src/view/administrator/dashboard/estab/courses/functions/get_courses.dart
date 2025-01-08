import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/CoursesModel.dart';

Future streamAccomplishemnt(course) async {
  const query = "users/establishment/view_all_courses.php";

  try {
    final response = await http.get(Uri.parse('${Server.host}$query'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      final List<CoursesModel> courses = jsonList
          .map((coursesData) => CoursesModel.fromJson(coursesData))
          .toList();
      course.add(courses);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<List<CoursesModel>> getCourses() async {
  const query = "users/establishment/view_all_courses.php";

  try {
    final response = await http.get(Uri.parse('${Server.host}$query'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);

      return jsonList
          .map((courseData) => CoursesModel.fromJson(courseData))
          .toList();
    } else {
      throw Exception('Failed to load courses');
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
