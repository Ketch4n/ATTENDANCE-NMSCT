import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BoxComponent extends StatelessWidget {
  BoxComponent(
      {super.key,
      required this.child,
      required this.count,
      required this.color});
  String child;
  String count;
  Color color;

  double screenHeight = 0;

  double screenWidth = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight / 5,
      width: screenWidth / 6,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              child,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Center(
            child: Text(
              count,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          // Text(
          //   "See more ->",
          //   style: TextStyle(color: Colors.white),
          // )
        ],
      ),
    );
  }
}
