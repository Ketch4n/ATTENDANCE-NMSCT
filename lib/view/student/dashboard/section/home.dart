import 'package:attendance_nmsct/view/student/dashboard/section/daily_report.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/section_tab.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_class.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_dtr.dart';
import 'package:flutter/material.dart';

class Section extends StatefulWidget {
  const Section({super.key, required this.ids, required this.name});
  final String ids;
  final String name;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section"),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Daily Report'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'DTR'),
          BottomNavigationBarItem(
              icon: Icon(Icons.class_), label: 'Section Tab'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
        currentIndex: current,
        onTap: (int index) {
          setState(() {
            current = index;
          });
        },
      ),
      body: IndexedStack(
        index: current,
        children: [
          DailyReport(name: widget.name),
          const StudentDTR(),
          const SectionTab(),
          StudentClass(ids: widget.ids, name: widget.name),
        ],
      ),
    );
  }
}
