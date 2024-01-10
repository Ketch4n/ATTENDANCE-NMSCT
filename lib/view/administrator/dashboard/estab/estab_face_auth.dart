import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/DailyReportModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/report.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EstabFaceAuth extends StatefulWidget {
  const EstabFaceAuth({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  State<EstabFaceAuth> createState() => _EstabFaceAuthState();
}

class _EstabFaceAuthState extends State<EstabFaceAuth> {
  final StreamController<List<DailyReportModel>> _dailyStream =
      StreamController<List<DailyReportModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> daily_report(dailyStream) async {
    try {
      String dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/daily_report.php'),
        body: {'id': widget.id, 'today': dateToday},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<DailyReportModel> dtr =
            data.map((dtrData) => DailyReportModel.fromJson(dtrData)).toList();
        // Add the list of classmates to the stream
        _dailyStream.add(dtr);
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

  Future refreshData() async {
    daily_report(_dailyStream);
  }

  @override
  void initState() {
    super.initState();
    daily_report(_dailyStream);
  }

  @override
  void dispose() {
    super.dispose();
    _dailyStream.close();
  }

  double screenHeight = 0;
  double screenWidth = 0;
  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  String error = '';
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refreshData,
      child: Scaffold(
          body: Column(
        children: [
          ListTile(
            leading: Text("Today"),
          ),
          Expanded(
            child: StreamBuilder<List<DailyReportModel>>(
                stream: _dailyStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<dynamic> snap = snapshot.data!;
                    if (snap.isEmpty) {
                      return ListView(
                        scrollDirection: Axis.vertical,
                        children: const [
                          Duck(),
                          Center(
                            child: Text(
                              'No record today yet !',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: snap.length,
                          itemBuilder: (context, index) {
                            final DailyReportModel dtr = snap[index];

                            return GestureDetector(
                              onTap: () {
                                showReport(context);
                              },
                              child: Card(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.green,
                                          // decoration: const BoxDecoration(
                                          //   color: Colors.blue,
                                          //   borderRadius: BorderRadius.only(
                                          //     topLeft: Radius.circular(20),
                                          //     topRight: Radius.circular(10),
                                          //     bottomLeft: Radius.circular(20),
                                          //     bottomRight: Radius.circular(80),
                                          //   ),
                                          // ),
                                          child: Text(
                                            dtr.lname,
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Time-In",
                                            style: TextStyle(
                                              fontFamily: "NexaRegular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            dtr.time_in_am == defaultValue
                                                ? defaultT
                                                : DateFormat('hh:mm ').format(
                                                        DateFormat('hh:mm:ss')
                                                            .parse(dtr
                                                                .time_in_am)) +
                                                    dtr.in_am,
                                            style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: screenWidth / 20,
                                            ),
                                          ),
                                          Text(
                                            "Time-In",
                                            style: TextStyle(
                                              fontFamily: "NexaRegular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            dtr.time_in_pm == defaultValue
                                                ? defaultT
                                                : DateFormat('hh:mm ').format(
                                                        DateFormat('hh:mm:ss')
                                                            .parse(dtr
                                                                .time_in_pm)) +
                                                    dtr.in_pm,
                                            style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: screenWidth / 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Time-Out",
                                            style: TextStyle(
                                              fontFamily: "NexaRegular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            dtr.time_out_am == defaultValue
                                                ? defaultT
                                                : DateFormat('hh:mm ').format(
                                                        DateFormat('hh:mm:ss')
                                                            .parse(dtr
                                                                .time_out_am)) +
                                                    dtr.out_am,
                                            style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: screenWidth / 20,
                                            ),
                                          ),
                                          Text(
                                            "Time-Out",
                                            style: TextStyle(
                                              fontFamily: "NexaRegular",
                                              fontSize: screenWidth / 25,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            dtr.time_out_pm == defaultValue
                                                ? defaultT
                                                : DateFormat('hh:mm ').format(
                                                        DateFormat('hh:mm:ss')
                                                            .parse(dtr
                                                                .time_out_pm)) +
                                                    dtr.out_pm,
                                            style: TextStyle(
                                              fontFamily: "NexaBold",
                                              fontSize: screenWidth / 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                // : const SizedBox()
                                ;
                          },
                        ),
                      );
                    }
                  } else if (snapshot.hasError || error.isNotEmpty) {
                    return Center(
                      child: Text(
                        error.isNotEmpty ? error : 'Failed to load data',
                        style: const TextStyle(
                            color: Colors
                                .red), // You can adjust the error message style
                      ),
                    );
                  } else {
                    return CardSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: true,
                    );
                  }
                }),
          ),
        ],
      )),
    );
  }
}
