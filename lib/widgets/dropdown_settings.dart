// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropdownSettings extends StatelessWidget {
  const DropdownSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAccountInfoTile(context),
        const SizedBox(height: 10),
      ],
    );
  }

  // Account Information Tile
  Widget _buildAccountInfoTile(BuildContext context) {
    return Padding(
      padding: Style.padding,
      child: GestureDetector(
        onTap: () => showProfileInfo(context),
        child: Container(
          height: 60,
          width: double.maxFinite,
          decoration: Style.boxdecor.copyWith(borderRadius: Style.radius12),
          child: const ListTile(
            title: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text("Account Information"),
              ],
            ),
            trailing: Icon(Icons.navigate_next),
          ),
        ),
      ),
    );
  }

  // Show Profile Info Modal
  Future<void> showProfileInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('internID');
    final idnumber = prefs.getString('internIDNUMBER');
    final contactnumber = prefs.getString('internCONTACTNUMBER');
    final section = prefs.getString('internSECTION');
    final semester = prefs.getString('internSEMESTER');
    final course = prefs.getString('internCOURSE');
    final sy = prefs.getString('internSY');

    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      barrierColor: Colors.black87.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.32,
        maxChildSize: 0.5,
        minChildSize: 0.32,
        builder: (context, scrollController) => Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 400,
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
                      _buildProfileInfoTile(
                          "Name", "${Session.fname} ${Session.lname}"),
                      _buildProfileInfoTile("ID #", idnumber),
                      _buildProfileInfoTile("Contact #", contactnumber),
                      _buildProfileInfoTile("Section", section),
                      _buildProfileInfoTile("Semester", semester),
                      _buildProfileInfoTile("Course", course),
                      _buildProfileInfoTile("School Year", sy),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create profile info ListTile
  Widget _buildProfileInfoTile(String title, String? value) {
    if (Session.role != 'INTERN' || value == null) return SizedBox();

    return ListTile(
      dense: true,
      leading: Text(
        "$title :",
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.blue, fontSize: 20),
      ),
    );
  }
}
