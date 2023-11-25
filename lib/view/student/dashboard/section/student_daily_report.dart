import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/view.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/view.dart';
import 'package:attendance_nmsct/view/student/dashboard/upload.dart';
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
  final TextEditingController _commentController = TextEditingController();

  int userId = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await bottomsheetUpload(
              context,
              widget.ids,
              widget.name,
              _commentController,
              // refreshCallback: _getImageReferences,
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [Tab(text: 'MetaData'), Tab(text: 'Accomplishment')],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                DateFormat('MMM dd, yyyy').format(DateTime.now()) + " - TODAY"),
            Expanded(
              child: TabBarView(
                children: [
                  MetaDataIndex(ids: widget.ids, name: widget.name),
                  AccomplishmentView(ids: widget.ids, name: widget.name)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future bottomsheetUpload(BuildContext context, String ids, String section,
    TextEditingController comment
    // {required Future<void> Function() refreshCallback,
    // required TextEditingController comment}
    ) async {
  showAdaptiveActionSheet(
      context: context,
      title: Text('Upload'),
      androidBorderRadius: 20,
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: const Text(
              'MetaData',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: (context) async {
              Navigator.of(context).pop(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: ((context) => Camera(name: section))),
              );

              // refreshCallback();
            }),

        // record == ''
        //     ?
        BottomSheetAction(
            title: const Text(
              'Daily Accomplishment',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: (context) async {
              Navigator.of(context).pop(false);
              await accomplishmentReport(context, ids, comment);
            })
      ]);
}
