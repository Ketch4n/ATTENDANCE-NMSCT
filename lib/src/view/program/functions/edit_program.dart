// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/src/components/circular_loading.dart';
import 'package:attendance_nmsct/src/components/snackbar.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/instance/text_editing_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<void> editProgramCourse(BuildContext context, int id, String abbr,
    String course, Function reload) async {
  if (abbr.isEmpty || course.isEmpty) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    customSnackBar(context, 1, "Course and Abbr cannot be empty!");
    Navigator.of(context).pop();
    return;
  }

  circularLoading(context);

  try {
    final response = await http.post(
      Uri.parse("${Server.host}users/establishment/program/edit_program.php"),
      body: json.encode({"id": id, "abbr": abbr, "course": course}),
    );
    print("ID: $id, Abbr: $abbr, Course: $course");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];
      final status = jsonResponse['status'];

      customSnackBar(context, status == "success" ? 0 : 1, message);
    } else {
      customSnackBar(
          context, 1, "Error: ${response.statusCode} ${response.reasonPhrase}");
    }
  } catch (e) {
    customSnackBar(context, 1, "An error occurred: $e");
  } finally {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    reload();
    InstanceTextEditing.clear();
  }
}
