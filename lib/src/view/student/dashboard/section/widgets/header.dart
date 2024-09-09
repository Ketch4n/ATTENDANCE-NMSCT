import 'package:attendance_nmsct/src/include/style.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatefulWidget {
  const SectionHeader({super.key, required this.name});
  final String name;

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      flexibleSpace: Stack(
        children: <Widget>[
          SizedBox(
            height: 90,
            width: double.maxFinite,
            child: Image.asset(
              "assets/images/blue.jpg",
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
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
                            height: 80,
                            width: 80,
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
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
