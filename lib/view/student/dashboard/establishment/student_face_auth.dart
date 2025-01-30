import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/TodayModel.dart';
import 'package:attendance_nmsct/face_recognition/pages/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentFaceAuth extends StatefulWidget {
  const StudentFaceAuth({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  State<StudentFaceAuth> createState() => _StudentFaceAuthState();
}

class _StudentFaceAuthState extends State<StudentFaceAuth> {
  final StreamController<TodayModel> _todayStream =
      StreamController<TodayModel>();
  late String latitude;
  late String longitude;

  bool isLoading = true; // Track if data is loading
  int userId = 0;
  double screenHeight = 0;
  double screenWidth = 0;
  final _idController = TextEditingController();

  late String checkInAM = "00:00:00";
  String inAMLat = "0.0";
  String inAMLong = "0.0";

  late String checkOutAM = "00:00:00";
  String outAMLat = "0.0";
  String outAMLong = "0.0";

  late String checkInPM = "00:00:00";
  String inPMLat = "0.0";
  String inPMLong = "0.0";

  late String checkOutPM = "00:00:00";
  String outPMLat = "0.0";
  String outPMLong = "0.0";

  String defaultValue = '00:00:00';
  String defaultT = '--/--';

  void today(todayStream) async {
    final response = await http.post(
      Uri.parse('${Server.host}users/student/today.php'),
      body: {
        'id': Session.id,
        'estab_id': widget.id,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      print("Response Data: $data");
      final today = TodayModel.fromJson(data);
      setState(() {
        checkInAM = today.time_in_am;
        inAMLat = today.in_am_lat;
        inAMLong = today.in_am_long;

        checkOutAM = today.time_out_am;
        outAMLat = today.out_am_lat;
        outAMLong = today.out_am_long;

        checkInPM = today.time_in_pm;
        inPMLat = today.in_pm_lat;
        inPMLong = today.in_pm_long;

        checkOutPM = today.time_out_pm;
        outPMLat = today.out_pm_lat;
        outPMLong = today.out_pm_long;

        print("CheckInAM: $checkInAM, InAMLat: $inAMLat, InAMLong: $inAMLong");
        print(
            "CheckOutAM: $checkOutAM, OutAMLat: $outAMLat, OutAMLong: $outAMLong");
        print("CheckInPM: $checkInPM, InPMLat: $inPMLat, InPMLong: $inPMLong");
        print(
            "CheckOutPM: $checkOutPM, OutPMLat: $outPMLat, OutPMLong: $outPMLong");
      });
    } else {
      print("Failed to load data. Status Code: ${response.statusCode}");
      throw Exception('Failed to load data');
    }
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      print("user don't enable location permission");
    }

    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        print("user denied location permission");
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      print("user denied permission forever");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  void _getLocation() async {
    try {
      Position currentPosition = await _determineUserCurrentPosition();
      setState(() {
        latitude = currentPosition.latitude.toString();
        longitude = currentPosition.longitude.toString();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void insertToday() async {
    try {
      if (checkInAM == "00:00:00") {
        setState(() {
          checkInAM = "00:00";
          inAMLat = latitude;
          inAMLong = longitude;
        });
      } else if (checkOutAM == "00:00:00") {
        setState(() {
          checkOutAM = "00:00";
          outAMLat = latitude;
          outAMLong = longitude;
        });
      } else if (checkInPM == "00:00:00") {
        setState(() {
          checkInPM = "00:00";
          inPMLat = latitude;
          inPMLong = longitude;
        });
      } else {
        setState(() {
          checkOutPM = "00:00";
          outPMLat = latitude;
          outPMLong = longitude;
        });
      }
    } catch (e) {}
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final estabId = widget.id;
    String defaultDATE = "server";
    String apiUrl = '${Server.host}users/student/insert_estab.php';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String jsonData =
        '{"student_id": "$userId", "estab_id": "$estabId","time_in_am":"$checkInAM","in_am_lat":"$inAMLat", "in_am_long":"$inAMLong","time_out_am":"$checkOutAM","out_am_lat":"$outAMLat","out_am_long":"$outAMLong","time_in_pm":"$checkInPM","in_pm_lat":"$inPMLat","in_pm_long":"$inPMLong","time_out_pm":"$checkOutPM","out_pm_lat":"$outPMLat","out_pm_long":"$outPMLong","date":"$defaultDATE"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    today(_todayStream);
    _todayStream.close();
  }

  bool _isIntervalLessThanFiveMinutes(String time1, String time2) {
    if (time1 == defaultValue || time2 == defaultValue) return false;
    final format = DateFormat('HH:mm:ss');
    final dateTime1 = format.parse(time1);
    final dateTime2 = format.parse(time2);
    final difference = dateTime2.difference(dateTime1).inMinutes;
    return difference < 5;
  }

  void _handleInsertToday(BuildContext context) {
    if (_isIntervalLessThanFiveMinutes(checkInAM, checkOutAM) ||
        _isIntervalLessThanFiveMinutes(checkOutAM, checkInPM) ||
        _isIntervalLessThanFiveMinutes(checkInPM, checkOutPM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Interval between actions is less than 5 minutes')),
      );
    } else {
      insertToday();
    }
  }

  @override
  void initState() {
    super.initState();
    _timeStream = fetchServerTime();
    today(_todayStream);
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _todayStream.close();
  }

  Stream<String> fetchServerTime() async* {
    while (true) {
      try {
        final response =
            await http.get(Uri.parse('${Server.host}server_time.php'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          yield data['time'];
        } else {
          yield 'Error fetching time';
        }
      } catch (e) {
        yield 'Error: $e';
      }
      await Future.delayed(Duration(seconds: 1)); // Update every second
    }
  }

  late Stream<String> _timeStream;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          StreamBuilder<String>(
            stream: _timeStream,
            builder: (context, snapshot) {
              String timeDisplay;
              if (snapshot.connectionState == ConnectionState.waiting) {
                timeDisplay = 'Loading...';
              } else if (snapshot.hasError) {
                timeDisplay = 'Error: ${snapshot.error}';
              } else if (!snapshot.hasData || snapshot.data == null) {
                timeDisplay = 'No data';
              } else {
                timeDisplay = snapshot.data!;
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  width: double.infinity,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      timeDisplay,
                      style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          checkInAM == defaultValue ||
                  checkOutAM == defaultValue ||
                  checkInPM == defaultValue ||
                  checkOutPM == defaultValue
              ? Flexible(
                  flex: 1,
                  child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FaceLauncherPage(
                                  purpose: 'auth',
                                  refreshCallback: () =>
                                      _handleInsertToday(context))));
                        },
                        child: Container(
                          decoration: Style.boxdecor,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: kIsWeb
                                  ? Center(child: Text("SCAN"))
                                  : Lottie.asset('assets/scan.json'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Flexible(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 32),
                    child: Text(
                      "You have completed this day!",
                      style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Time-In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        checkInAM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm a')
                                .format(DateFormat('hh:mm').parse(checkInAM)),
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Time-In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        checkInPM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm a')
                                .format(DateFormat('hh:mm').parse(checkInPM)),
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Time-Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        checkOutAM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm a')
                                .format(DateFormat('hh:mm').parse(checkOutAM)),
                        style: TextStyle(fontFamily: "NexaBold", fontSize: 20),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Time-Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        checkOutPM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm a')
                                .format(DateFormat('hh:mm').parse(checkOutPM)),
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: 20,
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
    );
  }
}
