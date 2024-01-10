import 'package:attendance_nmsct/view/administrator/create.dart';
import 'package:attendance_nmsct/view/student/dashboard/join.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

Future bottomsheetJoin(BuildContext context, String role,
    {required Future<void> Function() refreshCallback}) async {
  showAdaptiveActionSheet(
      context: context,
      title: Text(role == 'Intern' ? 'Join' : 'Create'),
      androidBorderRadius: 20,
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: const Text(
              'Establishment',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: "MontserratBold"),
            ),
            onPressed: (context) {
              String purpose = "Establishment";
              Navigator.of(context).pop(false);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => role == 'Intern'
                      ? Join(
                          role: role,
                          purpose: purpose,
                          refreshCallback: refreshCallback)
                      : CreateClassRoom(
                          role: role,
                          purpose: purpose,
                          refreshCallback: refreshCallback)));
            })
      ]);
}
