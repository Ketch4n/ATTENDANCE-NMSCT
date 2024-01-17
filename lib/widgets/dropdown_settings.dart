import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
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

  Future showProfileInfo(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        barrierColor: Colors.black87.withOpacity(0.5),
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.32,
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
                              "Name :",
                              style: TextStyle(color: Colors.black),
                            ),
                            trailing: Text(
                              Session.fname + Session.lname,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          ListTile(
                            leadingAndTrailingTextStyle:
                                TextStyle(fontSize: 20),
                            leading: Text(
                              "Email :",
                              style: TextStyle(color: Colors.black),
                            ),
                            trailing: Text(
                              Session.email,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          UserRole.role == 'Intern'
                              ? ListTile(
                                  leadingAndTrailingTextStyle:
                                      TextStyle(fontSize: 20),
                                  leading: Text(
                                    "ID :",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  trailing: Text(
                                    UserProfileInfo.uid,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : SizedBox(),
                          UserRole.role == 'Intern'
                              ? ListTile(
                                  leadingAndTrailingTextStyle:
                                      TextStyle(fontSize: 20),
                                  leading: Text(
                                    "Birth Date :",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  trailing: Text(
                                    UserProfileInfo.bday,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : SizedBox(),
                          UserRole.role == 'Intern'
                              ? ListTile(
                                  leadingAndTrailingTextStyle:
                                      TextStyle(fontSize: 20),
                                  leading: Text(
                                    "Address :",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  trailing: Text(
                                    UserProfileInfo.address,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
