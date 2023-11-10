import 'dart:async';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:attendance_nmsct/widgets/edit_profile.dart';
import 'package:flutter/material.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: <Widget>[
            Image.asset("assets/images/laptop.jpg"),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                    child: ClipRRect(
                        borderRadius: Style.borderRadius,
                        child: InkWell(
                          onTap: () {
                            showProfileEdit(context);
                          },
                          child: Image.asset(
                            'assets/images/admin.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        )),
                  ),
                  Text(
                    Session.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    Session.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const DropdownSettings(),
        // Padding(
        //   padding: Style.padding,
        //   child: Container(
        //     height: 90,
        //     width: double.maxFinite,
        //     decoration:
        //         Style.boxdecor.copyWith(borderRadius: Style.defaultradius),
        //     child: Flex(direction: Axis.horizontal, children: [
        //       Expanded(
        //           child: Column(
        //         children: [Icon(Icons.class_), Text("1"), Text("Section")],
        //       )),
        //       Expanded(
        //           child: Column(
        //         children: [Icon(Icons.room), Text("1"), Text("Establishment")],
        //       )),
        //       // Expanded(
        //       //     child: Column(
        //       //   children: [Text("436 h"), Icon(Icons.lock_clock)],
        //       // ))
        //     ]),
        //   ),
        // ),
        // SizedBox(
        //   height: 10,
        // ),

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       "Introducing",
        //       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        //     ),
        //     Text(
        //       "Face Recognition Feature",
        //       style: TextStyle(fontSize: 14, color: Colors.grey[800]),
        //     ),
        //   ],
        // ),
        // TextButton(
        //   onPressed: () {
        //     // logout(context);
        //   },
        //   child: Text("Logout"),
        // )
      ],
    );
  }
}
