import 'package:attendance_nmsct/auth/logout.dart';
import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/include/admin_list.dart';
import 'package:attendance_nmsct/include/slider.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_students.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  final Function(int) onMenuItemTap;

  const Navbar({super.key, required this.onMenuItemTap});
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
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
    return Consumer<UserRole>(builder: (context, user, child) {
      return SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 140,
                decoration: const BoxDecoration(),
                child: Column(
                  children: [
                    Stack(
                      children: <Widget>[
                        Container(
                          color: Colors.blue,
                          child: SizedBox(
                            height: 140,
                            width: double.maxFinite,
                            child: Image.asset(
                              'assets/images/neon.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: ClipRRect(
                                borderRadius: Style.radius50,
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const Profile(),
                                    //   ),
                                    // );
                                  },
                                  child: Image.asset(
                                    'assets/images/admin.png',
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Session.fname,
                                      style: Style
                                          .navbartxt), // Use null safety check
                                  Text(Session.email,
                                      // textScaleFactor:
                                      //     ScaleSize.textScaleFactor(
                                      //         context),
                                      style:
                                          const TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                            // StreamBuilder<UserModel>(
                            //   stream: _userStreamController.stream,
                            //   builder: (context, snapshot) {
                            //     if (snapshot.hasData) {
                            //       UserModel user =
                            //           snapshot.data!; // Add null safety check
                            //       return Padding(
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 15.0),
                            //         child: Column(
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.start,
                            //           children: [
                            //             Text(user.name,
                            //                 style: Style
                            //                     .navbartxt), // Use null safety check
                            //             Text(user.email,
                            //                 // textScaleFactor:
                            //                 //     ScaleSize.textScaleFactor(
                            //                 //         context),
                            //                 style: const TextStyle(
                            //                     color: Colors.white))
                            //           ],
                            //         ),
                            //       );
                            //     }
                            //     return Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 15.0),
                            //       child: Column(
                            //         mainAxisAlignment: MainAxisAlignment.start,
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Text("Username...",
                            //                   style: Style
                            //                       .navbartxt), // Use null safety check
                            //               Text("loading...",
                            //                   textScaleFactor:
                            //                       ScaleSize.textScaleFactor(
                            //                           context),
                            //                   style: const TextStyle(
                            //                       color: Colors.white))
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   },
                            // )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading:
                    Text(Session.role, style: const TextStyle(fontSize: 15)),
              ),
              // ListTile(
              //   leading: Icon(Icons.notification_add),
              //   trailing: Text("Notify"),
              //   onTap: () {
              //     AwesomeNotifications().createNotification(
              //         content: NotificationContent(
              //             id: 1,
              //             channelKey: "Flutter_Key",
              //             title: "Test",
              //             body: "Test"));
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.home_sharp),
                title: const Text('Home'),
                onTap: () {
                  widget.onMenuItemTap(0); // Change to index 0 (Page 1)
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  widget.onMenuItemTap(1); // Change to index 0 (Page 1)
                  Navigator.pop(context); // Close the drawer
                },
              ),
              Session.role == 'Administrator'
                  ? ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Establishment Radius'),
                      onTap: () {
                        Navigator.of(context).pop(false);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SliderPage()));
                      },
                    )
                  : SizedBox(),
              Session.role == 'SUPER ADMIN'
                  ? ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Add Admins'),
                      onTap: () {
                        Navigator.of(context).pop(false);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Signup(
                                  purpose: 'Create',
                                )));
                      },
                    )
                  : SizedBox(),
              Session.role == 'SUPER ADMIN'
                  ? ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('List of Admins'),
                      onTap: () {
                        Navigator.of(context).pop(false);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AdminList()));
                      },
                    )
                  : SizedBox(),
              user.role == 'NMSCST' ? Divider() : SizedBox(),
              user.role == 'NMSCST'
                  ? ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('All Establishment'),
                      onTap: () {
                        Navigator.of(context).pop(false);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AllEstablishment()));
                      },
                    )
                  : SizedBox(),
              user.role == 'NMSCST'
                  ? ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('All Students'),
                      onTap: () {
                        Navigator.of(context).pop(false);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AllStudents()));
                      },
                    )
                  : SizedBox(),
              const Divider(),
              // Session.role == 'Administrator'
              //     ? ListTile(
              //         title: const Text('Clear Database'),
              //         leading: const Icon(Icons.face),
              //         onTap: () async {
              //           await showDialog(
              //             context:
              //                 context, // Make sure to have access to the context
              //             builder: (BuildContext context) {
              //               return AlertDialog(
              //                 title: Text('Confirm Clear Database'),
              //                 content: Text(
              //                     'Are you sure you want to clear the database?'),
              //                 actions: [
              //                   TextButton(
              //                     onPressed: () {
              //                       Navigator.of(context)
              //                           .pop(); // Close the dialog
              //                     },
              //                     child: Text('Cancel'),
              //                   ),
              //                 ],
              //               );
              //             },
              //           );
              //         },
              //       )
              //     : SizedBox(),

              ListTile(
                title: const Text('Log-out'),
                leading: const Icon(Icons.exit_to_app),
                onTap: () async {
                  const purpose = "Logout";
                  Navigator.of(context).pop(false);
                  await logout(context, purpose);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
