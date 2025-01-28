import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/utils/styles/textstyle.dart';
import 'package:flutter/material.dart';

Widget programTitleHeader(String title) {
  return Container(
    height: 50,
    width: double.maxFinite,
    decoration: BoxDecoration(
        color: UtilsColorPallete.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
    child: Center(
        child: Text(
      "$title New Program / Course",
      style: UtilsTextStyle.h1,
    )),
  );
}
