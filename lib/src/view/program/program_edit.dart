import 'package:attendance_nmsct/src/components/textfield.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/view/program/functions/edit_program.dart';
import 'package:attendance_nmsct/src/view/program/modules/button_footer.dart';
import 'package:attendance_nmsct/src/view/program/modules/title_header.dart';
import 'package:flutter/material.dart';

class ProgramPageEdit extends StatefulWidget {
  const ProgramPageEdit({super.key, required this.id, required this.reload});
  final int id;
  final Function reload;

  @override
  State<ProgramPageEdit> createState() => _ProgramPageEditState();
}

class _ProgramPageEditState extends State<ProgramPageEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, minWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          programTitleHeader("Edit"),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 70,
                      width: double.maxFinite,
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: CustomTextField(
                          controller: controller.abbr,
                          label: "Abbreviation",
                          hint: "Example: BSIT",
                          fillcolor: UtilsColorPallete.grey,
                          readOnly: false),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 70,
                    width: double.maxFinite,
                    child: CustomTextField(
                        controller: controller.course,
                        label: "Course / Program",
                        hint: "Full course name",
                        fillcolor: UtilsColorPallete.grey,
                        readOnly: false),
                  )
                ],
              ),
            ),
          ),
          programButtonFooter(context, () {
            editProgramCourse(context, widget.id, controller.abbr.text,
                controller.course.text, widget.reload);
          }, widget.reload),
        ],
      ),
    );
  }
}
