import 'dart:async';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/box_component.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/components/add_course_dialog.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/components/edit_course_dialog.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/functions/get_courses.dart';
import 'package:attendance_nmsct/src/model/CoursesModel.dart';
import 'package:flutter/material.dart';

class AllCoursesPage extends StatefulWidget {
  const AllCoursesPage({super.key});

  @override
  State<AllCoursesPage> createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  final StreamController<List<CoursesModel>> _coursesController =
      StreamController<List<CoursesModel>>();

  @override
  void initState() {
    super.initState();
    streamAccomplishemnt(_coursesController);
  }

  @override
  void dispose() {
    _coursesController.close();
    super.dispose();
  }

  reload() {
    streamAccomplishemnt(_coursesController);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("All Courses"),
            const SizedBox(width: 20),
            Container(
                decoration: const BoxDecoration(color: Colors.green),
                child: IconButton(
                  onPressed: () {
                    showAddCourseDialog(context, reload);
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )),
          ],
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: width),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<List<CoursesModel>>(
                  stream: _coursesController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      final List<CoursesModel> data = snapshot.data!;
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const Duck(),
                              const Text('No Courses Yet',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    showAddCourseDialog(context, reload);
                                  },
                                  child: const Text("Add New Course"))
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final CoursesModel course = data[index];
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Stack(
                                children: [
                                  Card(
                                    child: Text(course.courses),
                                  ),
                                  Positioned(
                                      top: 5,
                                      right: 10,
                                      child: IconButton(
                                        onPressed: () {
                                          showEditCourseDialog(
                                              context,
                                              course.id,
                                              course.courses,
                                              reload);
                                        },
                                        icon: const Icon(Icons.edit),
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
