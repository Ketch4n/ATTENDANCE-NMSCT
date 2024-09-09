import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/auth/signup.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/SchoolYear.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/box_component.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/CoursesModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_students.dart';
import 'package:flutter/material.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final StreamController<List<CoursesModel>> _absentController =
      StreamController<List<CoursesModel>>();

  @override
  void initState() {
    super.initState();

    streamAccomplishemnt();
  }

  @override
  void dispose() {
    _absentController.close();

    super.dispose();
  }

  Future<void> streamAccomplishemnt() async {
    const query = "users/establishment/view_all_courses.php";

    try {
      final response = await http.get(
        Uri.parse('${Server.host}$query'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        final List<CoursesModel> absent = jsonList
            .map((absentData) => CoursesModel.fromJson(absentData))
            .toList();
        _absentController.add(absent);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load COURSES data: $e')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Courses"),
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
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Text("Student Courses",
              //       style: Theme.of(context).textTheme.headline6),
              // ),
              Expanded(
                child: StreamBuilder<List<CoursesModel>>(
                  stream: _absentController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      final List<CoursesModel> data = snapshot.data!;
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Duck(),
                              Text('No Student Courses Yet',
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => Signup(
                                                  purpose: 'INTERN',
                                                  reload: streamAccomplishemnt,
                                                )));
                                  },
                                  child: Text("Register Student"))
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final CoursesModel course = data[index];
                          return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => SchoolYearPage(
                                          course: course.course))),
                              child: Center(
                                child: BoxComponent(
                                  count: course.count,
                                  color: Colors.purple,
                                  child: course.course,
                                ),
                              )

                              //  Card(
                              //   child: ListTile(
                              //     title: Text(
                              //       course.course,
                              //     ),
                              //     trailing: Text(
                              //       course.count,
                              //       style: TextStyle(
                              //           fontSize: MediaQuery.of(context)
                              //               .textScaler
                              //               .scale(18)),
                              //     ),
                              //   ),
                              // ),
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
