import 'package:flutter/material.dart';

class StudentSectionTab extends StatefulWidget {
  const StudentSectionTab({super.key});

  @override
  State<StudentSectionTab> createState() => _StudentSectionTabState();
}

class _StudentSectionTabState extends State<StudentSectionTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Section Tab")),
    );
  }
}
