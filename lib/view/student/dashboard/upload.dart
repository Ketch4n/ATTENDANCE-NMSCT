import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future bottomsheetUpload(BuildContext context, String ids, String section,
    {required Future<void> Function() refreshCallback,
    required TextEditingController comment}) async {
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

              refreshCallback();
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
        // : BottomSheetAction(
        //     title: const Text(
        //       "Uploaded today",
        //       style: TextStyle(
        //           fontSize: 18,
        //           color: Colors.green,
        //           fontFamily: "MontserratBold"),
        //     ),
        //     onPressed: (context) {
        //       Navigator.of(context).pop(false);
        //     }),
      ]);
}
