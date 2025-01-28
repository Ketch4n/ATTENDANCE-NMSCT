import 'package:flutter/material.dart';

Future circularLoading(context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
}
