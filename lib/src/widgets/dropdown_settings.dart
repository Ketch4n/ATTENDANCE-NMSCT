// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/components/textfield.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropdownSettings extends StatelessWidget {
  const DropdownSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: Style.padding,
          child: GestureDetector(
            onTap: () {
              showProfileInfo(context);
            },
            child: Container(
                height: 60,
                width: double.maxFinite,
                decoration:
                    Style.boxdecor.copyWith(borderRadius: Style.radius12),
                child: const ListTile(
                  // textColor: Style.themecolor,
                  // iconColor: Style.themecolor,
                  title: Row(
                    children: [
                      Icon(Icons.security),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Security"),
                    ],
                  ),
                  trailing: Icon(Icons.navigate_next),
                )),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        // Padding(
        //   padding: Style.padding,
        //   child: Container(
        //       height: 60,
        //       width: double.maxFinite,
        //       decoration: Style.boxdecor.copyWith(borderRadius: Style.radius12),
        //       child: const ListTile(
        //         // textColor: Style.themecolor,
        //         // iconColor: Style.themecolor,
        //         title: Row(
        //           children: [
        //             Icon(Icons.lock),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             Text("Security and Privacy"),
        //           ],
        //         ),
        //         trailing: Icon(Icons.navigate_next),
        //       )),
        // ),
      ],
    );
  }

  changePass(context) async {
    if (controller.pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Provide new password above",
        style: TextStyle(color: Colors.blue),
      )));
    } else {
      try {
        final response = await http.post(
          Uri.parse("${Server.host}auth/change_pass.php"),
          body: jsonEncode(
              {"password": controller.pass.text, "email": Session.email}),
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Password Updated"),
            backgroundColor: Colors.green,
          ));
          controller.pass.clear();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future showProfileInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('internID');
    final bday = prefs.getString('internBDAY');
    final add = prefs.getString('internADDRESS');

    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        barrierColor: Colors.black87.withOpacity(0.5),
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              maxChildSize: 0.5,
              minChildSize: 0.32,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Divider(
                              color: Colors.black26,
                              thickness: 4,
                            ),
                          ),
                          ListTile(
                            leadingAndTrailingTextStyle:
                                TextStyle(fontSize: 20),
                            leading: Text(
                              "CHANGE PASSWORD",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          CustomTextField(
                              controller: controller.pass,
                              readOnly: false,
                              label: "New Password",
                              fillcolor: Colors.grey),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: MaterialButton(
                              onPressed: () {
                                changePass(context);
                              },
                              color: Colors.blue,
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          // ListTile(
                          //   leadingAndTrailingTextStyle:
                          //       TextStyle(fontSize: 20),
                          //   leading: Text(
                          //     "Email :",
                          //     style: TextStyle(color: Colors.black),
                          //   ),
                          //   trailing: Text(
                          //     Session.email,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: TextStyle(color: Colors.blue),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
