import 'package:flutter/material.dart';

Widget nodata() {
  return const Center(
    child: Text("No data available."),
  );
}

Widget circularLoading() {
  return const Center(child: CircularProgressIndicator());
}
