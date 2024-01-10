import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/report.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstabDTR extends StatefulWidget {
  const EstabDTR({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;
  @override
  State<EstabDTR> createState() => _EstabDTRState();
}

class _EstabDTRState extends State<EstabDTR> {
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  String error = '';
  double screenHeight = 0;
  double screenWidth = 0;
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

  Future<void> monthly_report(monthStream) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/monthly_report.php'),
        body: {'id': widget.id, 'month': _yearMonth},
      );
      print("TEST : $_yearMonth");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EstabTodayModel> dtr =
            data.map((dtrData) => EstabTodayModel.fromJson(dtrData)).toList();
        // Add the list of classmates to the stream
        _monthStream.add(dtr);
      } else {
        setState(() {
          error = 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
      });
    }
  }

  Future refreshData() async {
    monthly_report(_monthStream);
  }

  @override
  void initState() {
    super.initState();
    monthly_report(_monthStream);
  }

  @override
  void dispose() {
    super.dispose();
    _monthStream.close();
  }

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
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final month = await showMonthYearPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2099),
                );

                if (month != null) {
                  setState(() {
                    _month = DateFormat('MMMM').format(month);
                    _yearMonth = DateFormat('yyyy-MM').format(month);
                  });
                }
                monthly_report(_monthStream);
              },
              child: Text(
                _month,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "NexaBold",
                  // fontSize: screenWidth / 15,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<EstabTodayModel>>(
                  stream: _monthStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<dynamic> snap = snapshot.data!;
                      if (snap.isEmpty) {
                        return const Center(child: Text("NO DATA THIS MONTH"));
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: snap.length,
                            itemBuilder: (context, index) {
                              final EstabTodayModel dtr = snap[index];

                              return
                                  // DateFormat('MMMM').format(
                                  //             DateFormat('yyyy-mm-dd').parse(dtr.date)) ==
                                  //         _month
                                  //     ?
                                  GestureDetector(
                                onTap: () {
                                  showReport(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: index > 0 ? 12 : 0,
                                      bottom: 6,
                                      left: 6,
                                      right: 6),
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 20,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Container(
                                        margin: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(80),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(dtr.lname,
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  DateFormat('EE').format(
                                                      DateFormat('yyyy-mm-dd')
                                                          .parse(dtr.date)),
                                                  style: const TextStyle(
                                                      fontFamily: "NexaBold",
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  DateFormat('dd ').format(
                                                      DateFormat('yyyy-mm-dd')
                                                          .parse(dtr.date)),
                                                  style: const TextStyle(
                                                      fontFamily: "NexaBold",
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
