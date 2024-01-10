import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';

Widget userProfile() {
  return Padding(
    padding: const EdgeInsets.only(top: 25.0, bottom: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: ClipRRect(
              borderRadius: Style.radius50,
              child: Image.asset(
                "assets/images/admin.png",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Wrap(
            direction: Axis.vertical,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Session.fname),
              Text(
                Session.email,
                textScaleFactor: 0.7,
              )
            ],
          ),
        )
      ],
    ),
  );
}
