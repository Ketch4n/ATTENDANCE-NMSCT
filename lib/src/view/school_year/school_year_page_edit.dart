import 'package:attendance_nmsct/src/components/textfield.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/components/dialog/button_footer.dart';
import 'package:attendance_nmsct/src/components/dialog/title_header.dart';
import 'package:attendance_nmsct/src/view/school_year/functions/edit_school_year.dart';
import 'package:flutter/material.dart';

class SchoolYearPageEdit extends StatefulWidget {
  const SchoolYearPageEdit({super.key, required this.id, required this.reload});
  final int id;
  final Function reload;

  @override
  State<SchoolYearPageEdit> createState() => _SchoolYearPageEditState();
}

class _SchoolYearPageEditState extends State<SchoolYearPageEdit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, minWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          componentTitleHeader("Edit School Year"),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    width: double.maxFinite,
                    child: CustomTextField(
                        controller: controller.sy,
                        label: "School Year",
                        hint: "e.g. 2021-2022",
                        fillcolor: UtilsColorPallete.grey,
                        readOnly: false),
                  )
                ],
              ),
            ),
          ),
          componentButtonFooter(context, () {
            editSchoolYear(
              context,
              widget.id,
              controller.sy.text,
              widget.reload,
            );
          }, widget.reload),
        ],
      ),
    );
  }
}
