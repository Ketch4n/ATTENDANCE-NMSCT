import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';

Widget adminHeader(name) {
  return Stack(
    children: <Widget>[
      SizedBox(
        height: 50,
        width: double.maxFinite,
        child: Image.asset(
          "assets/images/blue.jpg",
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                ClipRRect(
                  borderRadius: Style.radius50,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        'assets/nmsct.jpg',
                        height: 70,
                        width: 70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      )
    ],
  );
}
