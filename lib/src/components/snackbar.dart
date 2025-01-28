import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar(
    context, int status, content) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: status == 0
          ? Colors.green
          : status == 1
              ? Colors.blue
              : Colors.grey,
    ),
  );
}
