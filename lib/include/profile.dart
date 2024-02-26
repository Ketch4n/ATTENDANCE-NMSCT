import 'dart:async';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/controller/User.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalProfile extends StatefulWidget {
  const GlobalProfile({super.key});

  @override
  State<GlobalProfile> createState() => _GlobalProfileState();
}

class _GlobalProfileState extends State<GlobalProfile> {
  // final StreamController<UserModel> _userStreamController =
  //     StreamController<UserModel>();

  // @override
  // void initState() {
  //   super.initState();
  //   fetchUser(_userStreamController);
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _userStreamController.close();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                kIsWeb ? SizedBox() : Image.asset("assets/images/laptop.jpg"),
                Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: kIsWeb
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                        child: ClipRRect(
                          borderRadius: Style.radius50,
                          // child: InkWell(
                          //   onTap: () {
                          //     // showGlobalProfileEdit(context);
                          //   },
                          child: Image.asset(
                            'assets/images/admin.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                          // )
                        ),
                      ),
                      // StreamBuilder<UserModel>(
                      //     stream: _userStreamController.stream,
                      //     builder: (context, snapshot) {
                      //       if (snapshot.hasData) {
                      //         UserModel user = snapshot.data!;
                      //         return Column(
                      //           crossAxisAlignment: kIsWeb
                      //               ? CrossAxisAlignment.center
                      //               : CrossAxisAlignment.start,
                      //           children: [
                      //             Text(
                      //               user.fname,
                      //               style: Style.profileText
                      //                   .copyWith(fontSize: 18),
                      //             ),
                      //             Text(
                      //               user.email,
                      //               style: TextStyle(
                      //                   fontSize: 12, color: Colors.grey[600]),
                      //             ),
                      //           ],
                      //         );
                      //       }
                      //       return const SizedBox();
                      //     }),
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
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
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
        ),
      ),
    );
  }
}

Future showGlobalProfileEdit(BuildContext context) async {
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
                fontFamily: "MontserratBold"),
          ),
          onPressed: (context) {
            Navigator.of(context).pop(false);
          }),
      BottomSheetAction(
          title: const Text(
            'Change Profile',
            style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: "MontserratBold"),
          ),
          onPressed: (context) {
            Navigator.of(context).pop(false);
          }),
    ],
    // cancelAction: CancelAction(
    //     title: const Text(
    //   'CANCEL',
    //   style: TextStyle(fontSize: 18, fontFamily: "MontserratBold"),
    // )), // onPressed parameter is optional by default will dismiss the ActionSheet
  );
}
