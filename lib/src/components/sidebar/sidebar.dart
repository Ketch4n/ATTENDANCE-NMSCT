// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/src/auth/logout.dart';
import 'package:attendance_nmsct/src/components/sidebar/modules/sidebar_header.dart';
import 'package:attendance_nmsct/src/components/sidebar/modules/sidebar_user_account.dart';
import 'package:attendance_nmsct/src/data/index/user_role_value.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_absent.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_outside.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/announcement.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IndexSideBar extends StatefulWidget {
  const IndexSideBar({
    super.key,
    required this.function,
  });
  final Function(int) function;

  @override
  State<IndexSideBar> createState() => _IndexSideBarState();
}

class _IndexSideBarState extends State<IndexSideBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      return Drawer(
        backgroundColor: UtilsColorPallete.grey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 170,
              child: Column(
                children: [
                  Stack(
                    children: <Widget>[
                      sidebarHeader(),
                      userAccount(),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Text(
                userRoleValue(Session.role!),
                style: const TextStyle(fontSize: 20),
              ),
              trailing: const Icon(
                Icons.circle,
                color: Colors.green,
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.home_sharp),
              title: const Text('Dashboard'),
              onTap: () {
                widget.function(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                widget.function(1);
              },
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Admin Accounts'),
              onTap: () {
                widget.function(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Establishment'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AllEstablishment()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Students'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CoursesPage(
                          year: '',
                        )));
              },
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Announcement'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => Announcement(
                            year: provider.selectedYearRange ??
                                provider.defaultYear,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_off_sharp),
              title: const Text('Outside Range'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AllOutsideRange(ids: provider.outsideIds),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: const Text('Absent'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => AllAbsentStudent(
                            year: provider.selectedYearRange ??
                                provider.defaultYear,
                          )),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timelapse_sharp),
              title: const Text('late'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AllOutsideRange(ids: provider.outsideIds),
                  ),
                );
              },
            ),
            const Divider(
              color: Colors.white,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Log-out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                const purpose = "Logout";
                await logout(context, purpose);
              },
            ),
          ],
        ),
      );
    });
  }
}
