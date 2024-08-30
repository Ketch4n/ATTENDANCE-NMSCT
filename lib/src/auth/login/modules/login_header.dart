import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';

Widget addLoginHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: Style.radius50,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/nmsct.jpg',
                height: 80,
                width: 80,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text("OJT Attendance\nMonitoring", style: Style.text),
      ],
    ),
  );
}
