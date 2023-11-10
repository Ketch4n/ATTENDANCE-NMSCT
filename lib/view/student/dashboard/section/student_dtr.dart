import 'package:flutter/material.dart';

class StudentDTR extends StatefulWidget {
  const StudentDTR({super.key});

  @override
  State<StudentDTR> createState() => _StudentDTRState();
}

class _StudentDTRState extends State<StudentDTR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Student DTR")),
    );
  }
}
