import 'dart:async';
import 'package:attendance_nmsct/src/controller/Read.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/RoomModel.dart';
import 'package:attendance_nmsct/src/widgets/else_statement.dart';
import 'package:flutter/material.dart';

class StudentSectionClass extends StatefulWidget {
  const StudentSectionClass({super.key, required this.ids, required this.name});
  final String ids;
  final String name;

  @override
  State<StudentSectionClass> createState() => _StudentSectionClassState();
}

class _StudentSectionClassState extends State<StudentSectionClass> {
  final StreamController<List<RoomModel>> _classmateStreamController =
      StreamController<List<RoomModel>>();

  @override
  void initState() {
    super.initState();
    fetchClassmates(_classmateStreamController, widget.ids);
  }

  @override
  void dispose() {
    _classmateStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Flex(
        direction: Axis.vertical,
        children: [
          ListTile(
              title: Text("Administrator", style: Style.classFont),
              subtitle: Style.classdivider),
          ListTile(
            leading: ClipRRect(
                borderRadius: Style.radius50,
                child: Image.asset(
                  "assets/images/estab.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                )),
            title: Text(Admin.name),
            subtitle: Text(
              Admin.email,
            ),
          ),
          ListTile(
              title: Text(
                "Classmates",
                style: Style.classFont,
              ),
              subtitle: Style.classdivider),
          StreamBuilder<List<RoomModel>>(
              stream: _classmateStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text("Waiting for Network"));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final List<RoomModel>? classmates = snapshot.data;
                if (classmates == null || classmates.isEmpty) {
                  return nodata(); // Ensure this is a valid widget or function
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: classmates.length,
                      itemBuilder: (context, index) {
                        final RoomModel classmate = classmates[index];
                        return ListTile(
                          leading: ClipRRect(
                              borderRadius: Style.radius50,
                              child: Image.asset(
                                "assets/images/admin.png",
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )),
                          title: Text(
                              classmate.student_id == Session.id
                                  ? "${classmate.fname} (You)"
                                  : classmate.fname,
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            classmate.email,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
