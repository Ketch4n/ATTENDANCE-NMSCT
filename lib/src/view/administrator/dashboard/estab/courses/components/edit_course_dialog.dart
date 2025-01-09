import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/functions/edit_course.dart';
import 'package:flutter/material.dart';

void showEditCourseDialog(context, String id, String currentCourse, reload) {
  final TextEditingController courseController =
      TextEditingController(text: currentCourse);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Course'),
        content: TextField(
          controller: courseController,
          decoration: const InputDecoration(
            labelText: 'Course Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              editCourse(id, courseController.text).then((value) => reload());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
