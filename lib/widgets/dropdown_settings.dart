import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';

class DropdownSettings extends StatelessWidget {
  const DropdownSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: Style.padding,
          child: Container(
              height: 60,
              width: double.maxFinite,
              decoration:
                  Style.boxdecor.copyWith(borderRadius: Style.defaultradius),
              child: const ListTile(
                // textColor: Style.themecolor,
                // iconColor: Style.themecolor,
                title: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Account Information"),
                  ],
                ),
                trailing: Icon(Icons.navigate_next),
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: Style.padding,
          child: Container(
              height: 60,
              width: double.maxFinite,
              decoration:
                  Style.boxdecor.copyWith(borderRadius: Style.defaultradius),
              child: const ListTile(
                // textColor: Style.themecolor,
                // iconColor: Style.themecolor,
                title: Row(
                  children: [
                    Icon(Icons.lock),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Security and Privacy"),
                  ],
                ),
                trailing: Icon(Icons.navigate_next),
              )),
        ),
      ],
    );
  }
}
