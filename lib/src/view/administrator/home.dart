// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api
import 'package:attendance_nmsct/src/components/connectivity.dart';
import 'package:attendance_nmsct/src/components/offline_snackbar.dart';
import 'package:attendance_nmsct/src/components/sidebar/sidebar.dart';
import 'package:attendance_nmsct/src/data/provider/page_index_value.dart';
import 'package:attendance_nmsct/src/view/administrator/admin_page.dart';
import 'package:attendance_nmsct/src/include/profile.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_page.dart';
import 'package:attendance_nmsct/src/view/faculty/faculty_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdministratorHome extends StatefulWidget {
  const AdministratorHome({super.key});

  @override
  _AdministratorHome createState() => _AdministratorHome();
}

class _AdministratorHome extends State<AdministratorHome> {
  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityProvider>().isOffline;
    final currentIndex = context.watch<PageIndexProvider>().currentIndex;

    return Scaffold(
      bottomNavigationBar:
          isOffline ? offlineSnackbar(isOffline) : const SizedBox(),
      body: Row(
        children: [
          IndexSideBar(
            function: (index) =>
                context.read<PageIndexProvider>().setIndex(index),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: const [
                DashBoardEstab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
