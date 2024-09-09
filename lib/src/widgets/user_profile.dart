import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:flutter/material.dart';

Widget userProfile() {
  return Padding(
    padding: const EdgeInsets.only(top: 25.0, bottom: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
            borderRadius: Style.radius50,
            child: Image.asset(
              "assets/images/admin.png",
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Wrap(
            direction: Axis.vertical,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Session.fname),
              Text(
                Session.email,
                textScaler: const TextScaler.linear(7),
              )
            ],
          ),
        )
      ],
    ),
  );
}
