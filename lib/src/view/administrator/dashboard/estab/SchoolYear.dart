import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/SchoolYearModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_students.dart';
import 'package:flutter/material.dart';

class SchoolYearPage extends StatefulWidget {
  const SchoolYearPage({super.key, required this.course});
  final String course;

  @override
  State<SchoolYearPage> createState() => _SchoolYearPageState();
}

class _SchoolYearPageState extends State<SchoolYearPage> {
  final StreamController<List<SchoolYearModel>> _absentController =
      StreamController<List<SchoolYearModel>>();

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
    const query = "users/establishment/view_all_school_year.php";
    final course = widget.course;
    try {
      final response =
          await http.post(Uri.parse('${Server.host}$query'), body: {
        'course': course,
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        final List<SchoolYearModel> absent = jsonList
            .map((absentData) => SchoolYearModel.fromJson(absentData))
            .toList();
        _absentController.add(absent);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load SCHOOL YEAR data: $e')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text("School Year"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Auth()));
              },
              icon: Icon(Icons.home))
        ],
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
              //   child: Text("School Year",
              //       style: Theme.of(context).textTheme.headline6),
              // ),
              Expanded(
                child: StreamBuilder<List<SchoolYearModel>>(
                  stream: _absentController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      final List<SchoolYearModel> data = snapshot.data!;
                      if (data.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              Duck(),
                              Text('No Courses Yet',
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final SchoolYearModel course = data[index];
                          final pass_course = widget.course;
                          return GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AllStudents(
                                          course: pass_course,
                                          sy: course.school_year,
                                        ))),
                            child: SizedBox(
                              height: 70,
                              child: Card(
                                child: ListTile(
                                  title: Text(course.school_year),
                                  trailing: Text(
                                    course.count,
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                            .textScaler
                                            .scale(18)),
                                  ),
                                ),
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
