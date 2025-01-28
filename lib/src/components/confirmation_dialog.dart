import 'package:flutter/material.dart';

Future<bool?> confirmationDialog(
    context, String title, String content, Function callback) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  ).then((value) async {
    if (value == true) {
      await callback();
    }
    return value;
  });
}
