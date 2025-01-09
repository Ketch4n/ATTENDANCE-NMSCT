import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/functions/add_course.dart';
import 'package:flutter/material.dart';

void showAddCourseDialog(context, reload) {
  final TextEditingController courseController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Course'),
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
              addCourse(courseController.text).then((value) => reload());
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
