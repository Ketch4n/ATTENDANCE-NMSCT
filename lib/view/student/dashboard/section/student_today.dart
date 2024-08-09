import 'package:attendance_nmsct/view/student/dashboard/establishment/student_estab_dtr.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/student_face_auth.dart';
import 'package:flutter/material.dart';

class StudentTodayFaceAuth extends StatefulWidget {
  const StudentTodayFaceAuth(
      {super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<StudentTodayFaceAuth> createState() => _StudentTodayFaceAuthState();
}

class _StudentTodayFaceAuthState extends State<StudentTodayFaceAuth> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Face Auth'), Tab(text: 'Records')],
            ),
            const SizedBox(
              height: 10,
            ),
            // Text(
            //     "${DateFormat('MMM dd, yyyy').format(DateTime.now())} - TODAY"),
            Expanded(
              child: TabBarView(
                children: [
                  StudentFaceAuth(id: widget.ids, name: widget.name),
                  StudentEstabDTR(id: widget.ids),
                  // MetaDataIndex(ids: widget.ids, name: widget.name),
                  // AccomplishmentView(ids: widget.ids, name: widget.name)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
