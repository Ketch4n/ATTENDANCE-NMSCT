import 'package:attendance_nmsct/view/administrator/dashboard/admin/admin_class.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/admin_dtr.dart';
import 'package:flutter/material.dart';

import 'admin_section_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.ids, required this.name});
  final String ids;
  // final String uid;
  final String name;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Administrator"),
      //   centerTitle: true,
      // ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Section'),
          BottomNavigationBarItem(
              icon: Icon(Icons.class_), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
        currentIndex: current,
        onTap: (int index) {
          setState(() {
            current = index;
          });
        },
      ),
      body: IndexedStack(
        index: current,
        children: [
          Admindtr(ids: widget.ids, name: widget.name),
          AdminSectionTab(
            ids: widget.ids,
            name: widget.name,
          ),
          AdminClass(ids: widget.ids, name: widget.name),
        ],
      ),
    );
  }
}
