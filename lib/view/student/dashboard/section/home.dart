import 'package:attendance_nmsct/view/student/dashboard/section/student_daily_report.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_section_tab.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_section_class.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_today.dart';
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
        flexibleSpace: Stack(
          children: <Widget>[
            Image.asset(
              "assets/images/blue.jpg", // Replace with your image path
              fit: BoxFit.cover, // Adjust the fit property as needed
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                foregroundColor: Colors.white,
                backgroundColor:
                    Colors.transparent, // Make the inner AppBar transparent
                elevation: 0.0,
                title: Text(widget.name),
                centerTitle: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.faceSmile), label: 'Auth'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendarDay), label: 'DTR'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.calendar_month), label: 'Accomplishment'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.building), label: 'On-site'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StudentTodayFaceAuth(ids: widget.ids, name: widget.name),
          StudentDailyReport(name: widget.name, ids: widget.ids),
          StudentSectionTab(name: widget.name, ids: widget.ids),
          StudentSectionClass(ids: widget.ids, name: widget.name),
        ],
      ),
    );
  }
}
