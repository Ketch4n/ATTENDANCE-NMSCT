import 'package:attendance_nmsct/view/student/dashboard/section/widgets/header.dart';
import 'package:flutter/material.dart';

class StudentSectionTab extends StatefulWidget {
  const StudentSectionTab({super.key, required this.name});
  final String name;
  @override
  State<StudentSectionTab> createState() => _StudentSectionTabState();
}

class _StudentSectionTabState extends State<StudentSectionTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Section Tab"));
  }
}
