import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/view.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/view.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_section_dtr.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDailyReport extends StatefulWidget {
  const StudentDailyReport({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<StudentDailyReport> createState() => _StudentDailyReportState();
}

class _StudentDailyReportState extends State<StudentDailyReport> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [
                // Tab(text: 'MetaData'),
                Tab(text: 'Accomplishment'),
                Tab(text: 'Records')
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MetaDataIndex(ids: widget.ids, name: widget.name),
                  // AccomplishmentView(ids: widget.ids, name: widget.name),
                  StudentSectionDTR(
                    name: widget.name,
                    ids: widget.ids,
                    section: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
