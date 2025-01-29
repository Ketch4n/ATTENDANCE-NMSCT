import 'package:attendance_nmsct/src/components/textfield.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/components/dialog/button_footer.dart';
import 'package:attendance_nmsct/src/components/dialog/title_header.dart';
import 'package:attendance_nmsct/src/view/school_year/functions/add_school_year.dart';
import 'package:flutter/material.dart';

class SchoolYearPageAdd extends StatefulWidget {
  const SchoolYearPageAdd({super.key, required this.reload});
  final Function reload;

  @override
  State<SchoolYearPageAdd> createState() => _SchoolYearPageAddState();
}

class _SchoolYearPageAddState extends State<SchoolYearPageAdd> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, minWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          componentTitleHeader("Add New School Year"),
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
            addSchoolYear(
              context,
              controller.sy.text,
              widget.reload,
            );
          }, widget.reload),
        ],
      ),
    );
  }
}
