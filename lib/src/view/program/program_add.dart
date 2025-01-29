import 'package:attendance_nmsct/src/components/textfield.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/view/program/functions/add_program.dart';
import 'package:attendance_nmsct/src/components/dialog/button_footer.dart';
import 'package:attendance_nmsct/src/components/dialog/title_header.dart';
import 'package:flutter/material.dart';

class ProgramPageAdd extends StatefulWidget {
  const ProgramPageAdd({super.key, required this.reload});
  final Function reload;

  @override
  State<ProgramPageAdd> createState() => _ProgramPageAddState();
}

class _ProgramPageAddState extends State<ProgramPageAdd> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, minWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          componentTitleHeader("Add New Program / Course"),
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
          componentButtonFooter(context, () {
            addProgramCourse(
              context,
              controller.abbr.text,
              controller.course.text,
              widget.reload,
            );
          }, widget.reload),
        ],
      ),
    );
  }
}
