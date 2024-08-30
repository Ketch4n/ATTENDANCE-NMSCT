import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/auth/login/login_page.dart';
import 'package:attendance_nmsct/src/pages/student/student_index.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String auth = "/auth";
  static const String login = "/login";
  static const String studentIndex = "student/index";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const Auth());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case studentIndex:
        return MaterialPageRoute(builder: (_) => const StudentIndex());

      default:
        return MaterialPageRoute(
          builder: (_) => const Auth(),
        );
    }
  }
}
