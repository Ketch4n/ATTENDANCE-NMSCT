import 'package:flutter/material.dart';

class StudentSectionDTR extends StatefulWidget {
  const StudentSectionDTR({super.key});

  @override
  State<StudentSectionDTR> createState() => _StudentSectionDTRState();
}

class _StudentSectionDTRState extends State<StudentSectionDTR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Student DTR")),
    );
  }
}
