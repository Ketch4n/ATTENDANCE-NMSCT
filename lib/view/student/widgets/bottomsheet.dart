import 'package:attendance_nmsct/view/student/dashboard/join.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

Future bottomsheetJoin(
    BuildContext context, String role, String section, String estab,
    {required Future<void> Function() refreshCallback}) async {
  showAdaptiveActionSheet(
      context: context,
      title: Text(role == 'Student' ? 'Join' : 'Create'),
      androidBorderRadius: 20,
      actions: role == 'Student'
          ? <BottomSheetAction>[
              section == 'null'
                  ? BottomSheetAction(
                      title: const Text(
                        'Section',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: "MontserratBold"),
                      ),
                      onPressed: (context) {
                        String purpose = "Section";
                        Navigator.of(context).pop(false);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Join(
                                role: role,
                                purpose: purpose,
                                refreshCallback: refreshCallback)));
                      })
                  : BottomSheetAction(
                      title: const Text(
                        "You're Already in a Section",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontFamily: "MontserratBold"),
                      ),
                      onPressed: (context) {
                        Navigator.of(context).pop(false);
                      }),
              estab == 'null'
                  ? BottomSheetAction(
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
                            builder: (context) => Join(
                                role: role,
                                purpose: purpose,
                                refreshCallback: refreshCallback)));
                      })
                  : BottomSheetAction(
                      title: const Text(
                        "Establishment Active",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontFamily: "MontserratBold"),
                      ),
                      onPressed: (context) {
                        Navigator.of(context).pop(false);
                      }),
            ]
          : role == 'Admin' || role == 'Establishment'
              ? <BottomSheetAction>[
                  BottomSheetAction(
                      title: Text(
                        role == 'Admin' ? 'Section' : 'Establishment',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: "MontserratBold"),
                      ),
                      onPressed: (context) {
                        String purpose =
                            role == 'Admin' ? 'Section' : 'Establishment';
                        Navigator.of(context).pop(false);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Join(
                                role: role,
                                purpose: purpose,
                                refreshCallback: refreshCallback)));
                      }),
                ]
              : List.empty());
}
