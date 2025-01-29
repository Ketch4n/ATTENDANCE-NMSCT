import 'package:attendance_nmsct/src/data/provider/session.dart';
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
          child: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeaderImage(),
                    _buildYearDropdownAndRefreshButton(provider),
                    _buildDashboardCards(context, provider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
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
    );
  }

  Widget _buildYearDropdownAndRefreshButton(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 810,
        ),
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
                items: provider.schoolYears.map((String yearRange) {
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
    );
  }

  Widget _buildDashboardCards(
      BuildContext context, DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: <Widget>[
          _buildDashboardCard(
            context,
            provider,
            'List of Late',
            provider.late,
            Icons.timelapse_sharp,
            () => AllLateStudent(
                year: provider.selectedYearRange ?? provider.defaultYear),
          ),
          _buildDashboardCard(
            context,
            provider,
            'Outside Range',
            provider.outside.toString(),
            Icons.location_off_sharp,
            () => AllOutsideRange(ids: provider.outsideIds),
          ),
          _buildDashboardCard(
            context,
            provider,
            'Absent',
            provider.absent,
            Icons.person_off_outlined,
            () => AllAbsentStudent(
                year: provider.selectedYearRange ?? provider.defaultYear),
          ),
          _buildDashboardCard(
            context,
            provider,
            'All Students',
            provider.count,
            Icons.school,
            () => CoursesPage(
                year: provider.selectedYearRange ?? provider.defaultYear),
          ),
          Session.role == "FACULTY"
              ? SizedBox()
              : _buildDashboardCard(
                  context,
                  provider,
                  'All Establishment',
                  provider.count_estab,
                  Icons.location_city,
                  () => const AllEstablishment(),
                ),
          Session.role == "FACULTY"
              ? SizedBox()
              : _buildDashboardCard(
                  context,
                  provider,
                  'Announcement',
                  provider.announcement,
                  Icons.mail,
                  () => Announcement(
                      year: provider.selectedYearRange ?? provider.defaultYear),
                ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    DashboardProvider provider,
    String title,
    dynamic count,
    IconData icon,
    Widget Function() pageBuilder,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => pageBuilder()),
        );
      },
      child: IndexCard(
        count: count,
        icon: icon,
        child: title,
      ),
    );
  }
}
