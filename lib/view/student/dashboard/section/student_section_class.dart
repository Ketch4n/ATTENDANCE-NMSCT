import 'dart:async';
import 'package:attendance_nmsct/controller/Read.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/ClassModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/widgets/header.dart';
import 'package:attendance_nmsct/widgets/no_data.dart';
import 'package:flutter/material.dart';

class StudentSectionClass extends StatefulWidget {
  const StudentSectionClass({super.key, required this.ids, required this.name});
  final String ids;
  final String name;
  @override
  State<StudentSectionClass> createState() => _StudentSectionClassState();
}

class _StudentSectionClassState extends State<StudentSectionClass> {
  final StreamController<List<ClassModel>> _classmateStreamController =
      StreamController<List<ClassModel>>();

  @override
  void initState() {
    super.initState();
    fetchClassmates(_classmateStreamController, widget.ids);
  }

  @override
  void dispose() {
    super.dispose();
    _classmateStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.vertical,
        children: [
          ListTile(
              title: Text("Administrator", style: Style.classFont),
              subtitle: Style.classdivider),
          ListTile(
            leading: ClipRRect(
                borderRadius: Style.borderRadius,
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
          StreamBuilder<List<ClassModel>>(
              stream: _classmateStreamController.stream,
              builder: (context, snapshot) {
                final List<ClassModel> classmates = snapshot.data!;
                if (snapshot.hasData) {
                  if (classmates.isEmpty) {
                    nodata;
                  }
                  return Expanded(
                    child: ListView.builder(
                        itemCount: classmates.length,
                        itemBuilder: (context, index) {
                          final ClassModel classmate = classmates[index];
                          return ListTile(
                            leading: ClipRRect(
                                borderRadius: Style.borderRadius,
                                child: Image.asset(
                                  "assets/images/admin.png",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )),
                            title: Text(
                                classmate.student_id == Session.id
                                    ? "${classmate.name} (You)"
                                    : classmate.name,
                                style: const TextStyle(fontSize: 18)),
                            subtitle: Text(
                              classmate.email,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
