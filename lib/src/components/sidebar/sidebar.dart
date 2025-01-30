// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/src/auth/logout.dart';
import 'package:attendance_nmsct/src/components/sidebar/modules/sidebar_header.dart';
import 'package:attendance_nmsct/src/components/sidebar/modules/sidebar_user_account.dart';
import 'package:attendance_nmsct/src/data/index/user_role_value.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/utils/styles/colorpallete.dart';
import 'package:attendance_nmsct/src/view/administrator/admin_page.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/SchoolYear.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_absent.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_late.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_outside.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/announcement.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_provider.dart';
import 'package:attendance_nmsct/src/view/faculty/faculty_page.dart';
import 'package:attendance_nmsct/src/view/program/program_page.dart';
import 'package:attendance_nmsct/src/view/school_year/school_year_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_nmsct/src/auth/signup.dart';

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
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Drawer(
        backgroundColor: UtilsColorPallete.grey,
        child: Consumer<DashboardProvider>(builder: (context, provider, child) {
          return ListView(
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
                  "${Session.role}",
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
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('School Year'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SchoolYearPage()));
                      },
                    ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Program / Course'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProgramCoursePage())),
                    ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
                      leading: const Icon(Icons.person_pin_sharp),
                      title: const Text('Faculty Accounts'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FacultyPage()));
                      },
                    ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : const Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Admin Accounts'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AdminPage()));
                      },
                    ),

              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
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
                trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Signup(
                                purpose: 'INTERN',
                                reload: () {},
                              )));
                    },
                    icon: Icon(Icons.add)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CoursesPage(
                            year: provider.selectedYearRange ??
                                provider.defaultYear,
                          )));
                },
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              Session.role == "FACULTY"
                  ? SizedBox()
                  : ListTile(
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
                      builder: (context) => AllLateStudent(
                          year: provider.selectedYearRange ??
                              provider.defaultYear),
                    ),
                  );
                },
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              // ListTile(
              //   leading: const Icon(Icons.archive),
              //   title: const Text('Archived'),
              //   onTap: () {},
              // ),
              ListTile(
                title: const Text('Log-out'),
                leading: const Icon(Icons.exit_to_app),
                onTap: () async {
                  const purpose = "Logout";
                  await logout(context, purpose);
                },
              ),
              SizedBox(
                height: 50,
              )
            ],
          );
        }),
      ),
    );
  }
}
