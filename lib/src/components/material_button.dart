import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/utils/styles/textstyle.dart';
import 'package:flutter/material.dart';

class CustomMaterialButton extends StatefulWidget {
  const CustomMaterialButton({
    super.key,
    required this.child,
    required this.icon,
    required this.function,
  });
  final String child;
  final IconData icon;
  final Function function;

  @override
  State<CustomMaterialButton> createState() => _CustomMaterialButtonState();
}

class _CustomMaterialButtonState extends State<CustomMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 60,
      minWidth: 150,
      color: UtilsColorPallete.primary,
      onPressed: () async {
        await widget.function();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.child,
            style: UtilsTextStyle.h1,
          ),
          Icon(
            widget.icon,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}
