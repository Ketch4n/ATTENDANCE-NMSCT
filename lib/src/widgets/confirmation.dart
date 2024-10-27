// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/src/controller/Delete.dart';
import 'package:attendance_nmsct/src/controller/Update_status.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Import SharedPreferences

Future confirm(BuildContext context, String id, String status) async {
  showDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          "Archived this Students ? ",
          style: Style.MontserratBold,
        ),
        content: Text("are you sure you want to continue?"),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              await updateUser(id, status);
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}