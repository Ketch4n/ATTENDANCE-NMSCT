import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:flutter/material.dart';

class InstanceTextEditing {
  // Singleton pattern to ensure a single instance
  static final InstanceTextEditing _instance = InstanceTextEditing._internal();

  factory InstanceTextEditing() => _instance;

  InstanceTextEditing._internal();

  // Publicly accessible TextEditingController
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  TextEditingController subject = TextEditingController();
  TextEditingController body = TextEditingController();

  TextEditingController abbr = TextEditingController();
  TextEditingController course = TextEditingController();

  // Dispose method to clean up resources
  void dispose() {
    email.dispose();
    pass.dispose();

    subject.dispose();
    body.dispose();

    abbr.dispose();
    course.dispose();
  }

  static void clear() {
    controller.email.clear();
    controller.pass.clear();

    controller.subject.clear();
    controller.body.clear();

    controller.abbr.clear();
    controller.course.clear();
  }
}
