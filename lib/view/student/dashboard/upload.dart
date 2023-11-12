import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future bottomsheetUpload(
    BuildContext context, String section, String date) async {
  showAdaptiveActionSheet(
      context: context,
      title: Text('Upload'),
      androidBorderRadius: 20,
      actions: <BottomSheetAction>[
        date !=
                DateFormat('MM-dd-yyyy').format(DateTime.now().toLocal()) +
                    ".jpg"
            ? BottomSheetAction(
                title: const Text(
                  'MetaData',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: "MontserratBold"),
                ),
                onPressed: (context) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: ((context) => Camera(name: section))),
                  );
                  Navigator.of(context).pop(false);
                })
            : BottomSheetAction(
                title: const Text(
                  "Uploaded Today",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontFamily: "MontserratBold"),
                ),
                onPressed: (context) {
                  Navigator.of(context).pop(false);
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
            onPressed: (context) {
              // String purpose = "Establishment";
              // Navigator.of(context).pop(false);
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => Join(
              //         role: role,
              //         purpose: purpose,
              //         refreshCallback: refreshCallback)));
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
