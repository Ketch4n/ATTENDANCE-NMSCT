import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_absent.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_late.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_outside.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/announcement.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/box_component.dart';

class DashBoardEstab extends StatelessWidget {
  const DashBoardEstab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 810,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/img/nmscst_bg.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: DropdownButtonFormField<String>(
                                value: provider.selectedYearRange,
                                decoration: const InputDecoration(
                                  label: Text("School Year"),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: provider.schoolYears
                                    .map((String yearRange) {
                                  return DropdownMenuItem<String>(
                                    value: yearRange,
                                    child: Text(yearRange),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  provider.setSelectedYearRange(newValue);
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: provider.refresh,
                              child: const Text("Reload Data / Refresh"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AllLateStudent(
                                            year: provider.selectedYearRange ??
                                                provider.defaultYear,
                                          )),
                                );
                              },
                              child: IndexCard(
                                count: provider.late,
                                icon: Icons.timelapse_sharp,
                                child: 'List of Late',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AllOutsideRange(
                                        ids: provider.outsideIds),
                                  ),
                                );
                              },
                              child: IndexCard(
                                count: provider.outside.toString(),
                                icon: Icons.location_off_sharp,
                                child: 'Outside Range',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => AllAbsentStudent(
                                            year: provider.selectedYearRange ??
                                                provider.defaultYear,
                                          )),
                                );
                              },
                              child: IndexCard(
                                count: provider.absent,
                                icon: Icons.person_off_outlined,
                                child: 'Absent',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AllEstablishment()),
                                );
                              },
                              child: IndexCard(
                                count: provider.count_estab,
                                icon: Icons.location_city,
                                child: 'All Establishment',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CoursesPage(
                                          year: provider.selectedYearRange ??
                                              provider.defaultYear,
                                        )));
                              },
                              child: IndexCard(
                                count: provider.count,
                                icon: Icons.school,
                                child: 'All Students',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => Announcement(
                                            year: provider.selectedYearRange ??
                                                provider.defaultYear,
                                          )),
                                );
                              },
                              child: IndexCard(
                                count: provider.announcement,
                                icon: Icons.mail,
                                child: 'Announcement',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
