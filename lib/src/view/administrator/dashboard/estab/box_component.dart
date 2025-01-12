import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/utils/styles/textstyle.dart';
import 'package:flutter/material.dart';

class IndexCard extends StatelessWidget {
  const IndexCard({
    super.key,
    required this.child,
    required this.count,
    required this.icon,
  });
  final String child;

  final String count;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: UtilsColorPallete.blue,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  child,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Center(
                child: Text(
                  count,
                  style: UtilsTextStyle.h1,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "See more ->",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon),
          ),
        ),
      ],
    );
  }
}
