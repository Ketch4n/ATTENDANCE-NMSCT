import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/src/model/CoursesModel.dart';
import 'package:attendance_nmsct/src/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/SchoolYear.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_absent.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_late.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_outside.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/all_students.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/announcement.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/box_component.dart';
import 'package:attendance_nmsct/src/view/student/calculate_distance.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:flutter/material.dart';

class DashBoardEstab extends StatefulWidget {
  const DashBoardEstab({super.key});

  @override
  State<DashBoardEstab> createState() => _DashBoardEstabState();
}

class _DashBoardEstabState extends State<DashBoardEstab> {
  final StreamController<List<CoursesModel>> _absentController =
      StreamController<List<CoursesModel>>();
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();
  final _schoolYearController = TextEditingController();
  String? _selectedYearRange;
  late String count = "";
  late String count_estab = "";
  late String absent = "";
  late String late = "";
  late double outside = 0;
  late String announcement = "";
  late List<String> outsideIds = [];

  @override
  void initState() {
    super.initState();
    fetchinterns();
    dtr();
    // streamAccomplishemnt();
  }

  @override
  void dispose() {
    _absentController.close();
    _monthStream.close();
    super.dispose();
  }

  List<String> get _yearRanges {
    int currentYear = DateTime.now().year;
    return List.generate(10, (index) {
      int startYear = currentYear - 5 + index;
      int endYear = startYear + 1;
      return "$startYear-$endYear";
    });
  }
  // Future<void> streamAccomplishemnt() async {
  //   const query = "users/establishment/view_all_courses.php";

  //   try {
  //     final response = await http.get(
  //       Uri.parse('${Server.host}$query'),
  //     );

  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonList = json.decode(response.body);
  //       final List<CoursesModel> absent = jsonList
  //           .map((absentData) => CoursesModel.fromJson(absentData))
  //           .toList();
  //       _absentController.add(absent);
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load COURSES data: $e')),
  //     );
  //   }
  // }

  Future<void> fetchinterns() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/count.php'),
        body: {"years": _schoolYearController.text},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          count = responseData['users'] ?? '0';
          count_estab = responseData['estab'] ?? '0';
          absent = responseData['absent'] ?? '0';
          late = responseData['late'] ?? '0';
          announcement = responseData['announcement'] ?? '';
        });
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  Future<void> dtr() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/student/outside.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final totalOutside = data.where((dtrData) {
          final dtrItem = EstabTodayModel.fromJson(dtrData);
          double meterValue = double.parse(dtrItem.radius ?? '0');
          double estabLat = double.parse(dtrItem.latitude ?? '0');
          double estabLong = double.parse(dtrItem.longitude ?? '0');

          List<double> distances = [
            calculateDistance(double.parse(dtrItem.in_am_lat ?? '0'),
                double.parse(dtrItem.in_am_long ?? '0'), estabLat, estabLong),
            calculateDistance(double.parse(dtrItem.out_am_lat ?? '0'),
                double.parse(dtrItem.out_am_long ?? '0'), estabLat, estabLong),
            calculateDistance(double.parse(dtrItem.in_pm_lat ?? '0'),
                double.parse(dtrItem.in_pm_long ?? '0'), estabLat, estabLong),
            calculateDistance(double.parse(dtrItem.out_pm_lat ?? '0'),
                double.parse(dtrItem.out_pm_long ?? '0'), estabLat, estabLong),
          ];

          if (distances.any((distance) => distance > meterValue)) {
            outsideIds.add(dtrItem.id.toString());
            return true;
          }
          return false;
        }).length;

        setState(() {
          outside = totalOutside.toDouble();
        });
        print("Total : $outsideIds");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    fetchinterns();
    dtr();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/nmscst_bg.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200, // Specify the desired width
                        height: 50, // Specify the desired height if needed
                        child: DropdownButtonFormField<String>(
                          value: _selectedYearRange,
                          decoration: InputDecoration(
                            label: Text("School Year"),
                          ),
                          items: _yearRanges.map((String yearRange) {
                            return DropdownMenuItem<String>(
                              value: yearRange,
                              child: Text(yearRange),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedYearRange = newValue;
                              _schoolYearController.text = newValue ?? '';
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: refresh,
                        child: const Text("Reload Data / Refresh"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0, // spacing between cards
                    runSpacing: 8.0, // spacing between rows
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AllLateStudent()),
                          );
                        },
                        child: BoxComponent(
                          count: late,
                          child: 'List of Late',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllOutsideRange(ids: outsideIds),
                            ),
                          );
                        },
                        child: BoxComponent(
                          count: outside.toString(),
                          child: 'Outside Range',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AllAbsentStudent()),
                          );
                        },
                        child: BoxComponent(
                          count: absent,
                          child: 'Absent',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AllEstablishment()),
                          );
                        },
                        child: BoxComponent(
                          count: count_estab,
                          child: 'All Establishment',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CoursesPage()));
                        },
                        child: BoxComponent(
                          count: count,
                          child: 'All Students',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const Announcement()),
                          );
                        },
                        child: BoxComponent(
                          count: announcement,
                          child: 'Announcement',
                        ),
                      ),

                      // SizedBox(
                      //   height: 100,
                      //   width: 800,
                      //   child: StreamBuilder<List<CoursesModel>>(
                      //       stream: _absentController.stream,
                      //       builder: (context, snapshot) {
                      //         if (snapshot.hasError) {
                      //           return Center(
                      //               child: Text("Error: ${snapshot.error}"));
                      //         } else if (snapshot.hasData) {
                      //           final courses = snapshot.data!;
                      //           return ListView.builder(
                      //             scrollDirection: Axis.horizontal,
                      //             itemCount: courses.length,
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               final course = courses[index];
                      //               return Padding(
                      //                 padding:
                      //                     const EdgeInsets.only(right: 8.0),
                      //                 child: GestureDetector(
                      //                   onTap: () {
                      //                     Navigator.of(context).push(
                      //                         MaterialPageRoute(
                      //                             builder: (context) =>
                      //                                 SchoolYearPage(
                      //                                   course: course.course,
                      //                                 )));
                      //                   },
                      //                   child: SizedBox(
                      //                     width: 196,
                      //                     child: BoxComponent(
                      //                       count: course.count,
                      //                       color: Colors.purple,
                      //                       child: course.course,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           );
                      //         } else {
                      //           return Center(child: Duck());
                      //         }
                      //       }),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
