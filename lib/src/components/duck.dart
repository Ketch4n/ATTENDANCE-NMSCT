import 'package:flutter/material.dart';

class Duck extends StatelessWidget {
  const Duck({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      child: SizedBox(
        height: 80,
        width: 80,
        child: Image.asset(
          "assets/duck.gif",
        ),
      ),
    );
  }
}
