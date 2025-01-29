import 'package:attendance_nmsct/src/components/material_button.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:flutter/material.dart';

Widget componentButtonFooter(context, function, reload) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.abbr.clear();
                  controller.course.clear();
                },
                child: const Text("Cancel"))),
        Flexible(
          flex: 2,
          child: CustomMaterialButton(
              child: "Save ", icon: Icons.save, function: () => function()),
        ),
      ],
    ),
  );
}
