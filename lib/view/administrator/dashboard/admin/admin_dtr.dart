import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:flutter/material.dart';

class Admindtr extends StatefulWidget {
  const Admindtr({super.key, required this.name});
  final String name;
  @override
  State<Admindtr> createState() => _AdmindtrState();
}

class _AdmindtrState extends State<Admindtr> {
  bool isLoading = true; // Track if data is loading
  int userId = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: <Widget>[
            SizedBox(
              height: 80,
              width: double.maxFinite,
              child: Image.asset(
                "assets/images/blue.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      ClipRRect(
                        borderRadius: Style.borderRadius,
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
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        const DropdownSettings(),
        //  Expanded(
        //   child: CardListSkeleton(
        //     isCircularImage: true,
        //     isBottomLinesActive: true,
        //     length: 1,
        //   ),
        // )
      ],
    );
  }
}
