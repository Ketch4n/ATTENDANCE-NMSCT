import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

Future showProfileEdit(BuildContext context) async {
  showAdaptiveActionSheet(
    context: context,
    title: const Text('Profile Photo'),
    androidBorderRadius: 20,
    actions: <BottomSheetAction>[
      BottomSheetAction(
          title: const Text(
            'Upload New',
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: "MontserratBold"),
          ),
          onPressed: (context) {
            Navigator.of(context).pop(false);
          }),
    ],
    cancelAction: CancelAction(
        title: const Text(
      'CANCEL',
      style: TextStyle(fontSize: 18, fontFamily: "MontserratBold"),
    )), // onPressed parameter is optional by default will dismiss the ActionSheet
  );
}
