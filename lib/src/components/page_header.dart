import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/utils/styles/textstyle.dart';
import 'package:flutter/material.dart';

Widget indexPagesHeader(String child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            child: Image.asset(
              'assets/img/nmscst_name.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Container(
            height: 50,
            constraints: const BoxConstraints(
              maxWidth: 1294,
            ),
            decoration: BoxDecoration(
              color: UtilsColorPallete.blue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                child,
                style: UtilsTextStyle.h1,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
