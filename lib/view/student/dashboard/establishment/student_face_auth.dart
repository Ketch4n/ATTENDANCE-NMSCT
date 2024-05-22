import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/TodayModel.dart';
import 'package:attendance_nmsct/pages/home.dart';
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
  // Location _location = Location();
  // LocationData? currentLocation;
  late String latitude;
  late String longitude;
  late String coordinate;

  bool isLoading = true; // Track if data is loading
  int userId = 0;
  double screenHeight = 0;
  double screenWidth = 0;
  final _idController = TextEditingController();

  String checkInAM = "00:00:00";
  String inAMLat = "0.0";
  String inAMLong = "0.0";

  String checkOutAM = "00:00:00";
  String outAMLat = "0.0";
  String outAMLong = "0.0";

  String checkInPM = "00:00:00";
  String inPMLat = "0.0";
  String inPMLong = "0.0";

  String checkOutPM = "00:00:00";
  String outPMLat = "0.0";
  String outPMLong = "0.0";

  String defaultValue = '00:00:00';
  String defaultT = '--/--';

  DateFormat format = DateFormat("hh:mm a");

  // Future sharedPref() async {
  //    final prefs = await SharedPreferences.getInstance();
  //    final timeINAM = prefs.getString('timeINAM');
  //    final timeOUTAM = prefs.getString('timeOUTAM');
  //    final timeINPM = prefs.getString('timeINPM');
  //    final timeOUTPM = prefs.getString('timeOUTPM');

  //    setState(() {
  //       checkInAM = timeINAM!;
  //       checkOutAM = timeOUTAM!;
  //       checkInPM = timeINPM!;
  //       checkOutPM = timeOUTPM!;
  //    });

  // }
  void today(todayStream) async {
    final response = await http.post(
      Uri.parse('${Server.host}users/student/today.php'),
      body: {
        'id': Session.id,
        'estab_id': widget.id,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now())
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
      });

      // todayStream.add(today);
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

  // String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  void insertToday() async {
    try {
      if (checkInAM == "00:00:00") {
        setState(() {
          checkInAM = DateFormat('HH:mm').format(DateTime.now());
          inAMLat = latitude;
          inAMLong = longitude;
        });
      } else if (checkOutAM == "00:00:00") {
        setState(() {
          checkOutAM = DateFormat('HH:mm').format(DateTime.now());
          outAMLat = latitude;
          outAMLong = longitude;
        });
      } else if (checkInPM == "00:00:00") {
        setState(() {
          checkInPM = DateFormat('HH:mm').format(DateTime.now());
          inPMLat = latitude;
          inPMLong = longitude;
        });
      } else {
        setState(() {
          checkOutPM = DateFormat('HH:mm').format(DateTime.now());
          outPMLat = latitude;
          outPMLong = longitude;
        });
      }
    } catch (e) {}
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final estabId = widget.id;
    String defaultDATE = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String apiUrl = '${Server.host}users/student/insert_estab.php';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String jsonData =
        '{"student_id": "$userId", "estab_id": "$estabId","time_in_am":"$checkInAM","in_am_lat":"$inAMLat", "in_am_long":"$inAMLong","time_out_am":"$checkOutAM","out_am_lat":"$outAMLat","out_am_long":"$outAMLong","time_in_pm":"$checkInPM","in_pm_lat":"$inPMLat","in_pm_long":"$inPMLong","time_out_pm":"$checkOutPM","out_pm_lat":"$outPMLat","out_pm_long":"$outPMLong","date":"$defaultDATE"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    today(_todayStream);
    _todayStream.close();
  }

  @override
  void initState() {
    super.initState();
    // sharedPref();
    today(_todayStream);
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _todayStream.close();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  width: double.maxFinite,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      DateFormat('hh:mm:ss a').format(DateTime.now()),
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
                                  refreshCallback: insertToday)));
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
                                .format(DateFormat('hh:mm').parse(checkInAM))
                        //     +
                        // inAM
                        ,
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
                                .format(DateFormat('hh:mm').parse(checkInPM))
                        //     +
                        // inPM
                        ,
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
                                .format(DateFormat('hh:mm').parse(checkOutAM))
                        //     +
                        // outAM
                        ,
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
                                .format(DateFormat('hh:mm').parse(checkOutPM))
                        //     +
                        // outPM
                        ,
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
