import 'package:attendance_nmsct/view/student/dashboard/section/daily_report.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/section_tab.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_class.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_dtr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Section extends StatefulWidget {
  const Section({super.key, required this.ids, required this.name});
  final String ids;
  final String name;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section"),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendarDay), label: 'DTR'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Attendance'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.book), label: 'Class'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
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
