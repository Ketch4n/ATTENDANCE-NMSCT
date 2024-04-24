import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_students.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/box_component.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/index.dart';
import 'package:attendance_nmsct/view/student/calculate_distance.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';

class DashBoardEstab extends StatefulWidget {
  const DashBoardEstab({super.key});

  @override
  State<DashBoardEstab> createState() => _DashBoardEstabState();
}

class _DashBoardEstabState extends State<DashBoardEstab> {
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();
  late String count = "";
  late String count_estab = "";
  late String absent = "";
  late String late = "";
  late double outside = 0;

  Future<void> fetchinterns() async {
    final response = await http.get(
      Uri.parse('${Server.host}users/establishment/count.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        count = responseData['users'];
        count_estab = responseData['estab'];
        absent = responseData['absent'];
        late = responseData['late'];
        // outside = responseData['outside'];
      });
      // Extract the count of users
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> dtr() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/student/outside.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EstabTodayModel> dtr =
            data.map((dtrData) => EstabTodayModel.fromJson(dtrData)).toList();
        _monthStream.add(dtr);
        final dtr2 = dtr[0];

        double meterValue = double.parse(dtr2.radius ?? '0');

        double INAMLAT = double.parse(dtr2.in_am_lat ?? '0');
        double INAMLONG = double.parse(dtr2.in_am_long ?? '0');

        double OUTAMLAT = double.parse(dtr2.out_am_lat ?? '0');
        double OUTAMLONG = double.parse(dtr2.out_am_long ?? '0');

        double INPMLAT = double.parse(dtr2.in_pm_lat ?? '0');
        double INPMLONG = double.parse(dtr2.in_pm_long ?? '0');

        double OUTPMLAT = double.parse(dtr2.out_pm_lat ?? '0');
        double OUTPMLONG = double.parse(dtr2.out_pm_long ?? '0');

        double estabLat = double.parse(dtr2.latitude ?? '0');
        double estabLong = double.parse(dtr2.longitude ?? '0');

// List of distances
        List<double> distances = [
          calculateDistance(INAMLAT, INAMLONG, estabLat, estabLong),
          calculateDistance(OUTAMLAT, OUTAMLONG, estabLat, estabLong),
          calculateDistance(INPMLAT, INPMLONG, estabLat, estabLong),
          calculateDistance(OUTPMLAT, OUTPMLONG, estabLat, estabLong),
        ];

// Iterate over the distances using a for loop
        for (int i = 0; i < distances.length; i++) {
          if (distances[i] > meterValue) {
            outside++;
          }
        }
      } else {
        setState(() {
          // error = 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        // error = 'An error occurred: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fetchinterns();
    dtr();
  }

  double screenHeight = 0;
  double screenWidth = 0;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.maxFinite,
                  child: Image.asset(
                    'assets/nmscst_bg.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0, // spacing between cards
                    runSpacing: 8.0, // spacing between rows
                    children: <Widget>[
                      BoxComponent(
                        color: Colors.red,
                        count: late,
                        child: 'List of Late',
                      ),
                      BoxComponent(
                        count: outside.toString(),
                        color: Colors.orange,
                        child: 'Outside Range',
                      ),
                      BoxComponent(
                        count: absent,
                        color: Colors.blue,
                        child: 'Absent',
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AllEstablishment())),
                        child: Stack(
                          children: [
                            BoxComponent(
                              count: count_estab,
                              color: Colors.green,
                              child: 'All Establishment',
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "See more ->",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AllStudents())),
                        child: Stack(
                          children: [
                            BoxComponent(
                              count: count,
                              color: Colors.purple,
                              child: 'All Students',
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "See more ->",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
