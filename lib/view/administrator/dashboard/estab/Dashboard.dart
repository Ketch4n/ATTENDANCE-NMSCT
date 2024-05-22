import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_absent.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_establishment.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_late.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_outside.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_students.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/announcement.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/box_component.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/index.dart';
import 'package:attendance_nmsct/view/student/calculate_distance.dart';
import 'package:flutter/cupertino.dart';
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
  late String announcement = "";
  late List<String> outsideIds = [];

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
        announcement = responseData['announcement'];
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
        final totalOutside = data.where((dtrData) {
          final dtrItem = EstabTodayModel.fromJson(dtrData);
          double meterValue = double.parse(dtrItem.radius ?? '0');
          double INAMLAT = double.parse(dtrItem.in_am_lat ?? '0');
          double INAMLONG = double.parse(dtrItem.in_am_long ?? '0');
          double OUTAMLAT = double.parse(dtrItem.out_am_lat ?? '0');
          double OUTAMLONG = double.parse(dtrItem.out_am_long ?? '0');
          double INPMLAT = double.parse(dtrItem.in_pm_lat ?? '0');
          double INPMLONG = double.parse(dtrItem.in_pm_long ?? '0');
          double OUTPMLAT = double.parse(dtrItem.out_pm_lat ?? '0');
          double OUTPMLONG = double.parse(dtrItem.out_pm_long ?? '0');
          double estabLat = double.parse(dtrItem.latitude ?? '0');
          double estabLong = double.parse(dtrItem.longitude ?? '0');

          List<double> distances = [
            calculateDistance(INAMLAT, INAMLONG, estabLat, estabLong),
            calculateDistance(OUTAMLAT, OUTAMLONG, estabLat, estabLong),
            calculateDistance(INPMLAT, INPMLONG, estabLat, estabLong),
            calculateDistance(OUTPMLAT, OUTPMLONG, estabLat, estabLong),
          ];

          if (distances.any((distance) => distance > meterValue)) {
            outsideIds.add(dtrItem.id);
            return true;
          }
          // for (int i = 0; i < distances.length; i++) {
          //   if () {

          //   }

          // }

          return false;
        }).length;

        setState(() {
          outside = totalOutside.toDouble();
        });
        print("Total : $outsideIds");
        print("Total : $outsideIds");
      } else {
        setState(() {
          // Handle error
        });
      }
    } catch (e) {
      setState(() {
        // Handle error
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
                  height: 370,
                  width: double.maxFinite,
                  child: Image.asset(
                    'assets/nmscst_bg.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0, // spacing between cards
                    runSpacing: 8.0, // spacing between rows
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AllLateStudent()));
                        },
                        child: BoxComponent(
                          color: Colors.red,
                          count: late,
                          child: 'List of Late',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AllOutsideRange(
                                    ids: outsideIds,
                                  )));
                        },
                        child: BoxComponent(
                          count: outside.toString(),
                          color: Colors.orange,
                          child: 'Outside Range',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => AllAbsentStudent())));
                        },
                        child: BoxComponent(
                          count: absent,
                          color: Colors.blue,
                          child: 'Absent',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AllEstablishment())),
                        child: BoxComponent(
                          count: count_estab,
                          color: Colors.green,
                          child: 'All Establishment',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AllStudents())),
                        child: BoxComponent(
                          count: count,
                          color: Colors.purple,
                          child: 'All Students',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Announcement()));
                        },
                        child: BoxComponent(
                          count: announcement,
                          color: Colors.grey,
                          child: 'Announcement',
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
