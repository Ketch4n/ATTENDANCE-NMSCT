import 'dart:async';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/widgets/dropdown_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalProfile extends StatelessWidget {
  const GlobalProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Stack(
                children: [
                  if (!kIsWeb) Image.asset("assets/images/laptop.jpg"),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Column(
                      crossAxisAlignment: kIsWeb
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                          child: ClipRRect(
                            borderRadius: Style.radius50,
                            child: Image.asset(
                              'assets/images/admin.png',
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: kIsWeb
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              Session.fname,
                              style: Style.profileText.copyWith(fontSize: 18),
                            ),
                            Text(
                              Session.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const DropdownSettings(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showGlobalProfileEdit(BuildContext context) async {
  showAdaptiveActionSheet(
    context: context,
    title: const Text('Edit Profile Photo'),
    androidBorderRadius: 20,
    actions: <BottomSheetAction>[
      BottomSheetAction(
        title: const Text(
          'Edit Details',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: "MontserratBold",
          ),
        ),
        onPressed: (context) {
          Navigator.of(context).pop();
        },
      ),
      BottomSheetAction(
        title: const Text(
          'Change Profile',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: "MontserratBold",
          ),
        ),
        onPressed: (context) {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
