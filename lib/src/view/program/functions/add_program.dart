// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:attendance_nmsct/src/components/circular_loading.dart';
import 'package:attendance_nmsct/src/components/snackbar.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/instance/text_editing_controller.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

Future<void> addProgramCourse(
    BuildContext context, String abbr, String course, reload) async {
  if (abbr.isEmpty || course.isEmpty) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    customSnackBar(context, 1, "Course and Abbr cannot be empty !");
    Navigator.of(context).pop();
  } else {
    circularLoading(context);

    try {
      final response = await http.post(
          Uri.parse(
              "${Server.host}users/establishment/program/add_program.php"),
          body: {
            'abbr': abbr,
            'course': course,
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        String message = jsonResponse['message'];
        String quack = jsonResponse['status'];

        if (quack == "success") {
          customSnackBar(context, 0, message);
        } else {
          customSnackBar(context, 1, message);
        }
      } else {
        // print("Error: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      // print("An error occurred while fetching announcement data: $e");
    } finally {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      reload();
      InstanceTextEditing.clear();
    }
  }
}
