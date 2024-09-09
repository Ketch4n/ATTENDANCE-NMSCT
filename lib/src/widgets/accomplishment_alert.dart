// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/src/include/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> accAlertDialog(
    BuildContext context, String title, String message) async {
  // Navigator.of(context).popUntil((route) => route.isFirst);
  await showDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: Style.MontserratBold.copyWith(
              color: title == 'Success' || title == 'Login success'
                  ? Colors.green
                  : Colors.orange),
        ),
        content: Text(
          message,
          style: Style.MontserratRegular,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ok'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}
