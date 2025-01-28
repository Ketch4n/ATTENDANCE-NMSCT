import 'package:attendance_nmsct/src/components/material_button.dart';
import 'package:attendance_nmsct/src/components/show_dialog.dart';
import 'package:attendance_nmsct/src/view/program/program_add.dart';
import 'package:flutter/material.dart';

Widget addNewButton(context, reload) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: CustomMaterialButton(
          child: "Add New",
          icon: Icons.add_box,
          function: () {
            showCustomDialog(context, ProgramPageAdd(reload: reload));
          },
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}
