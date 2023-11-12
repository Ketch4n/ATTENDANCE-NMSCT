import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/TodayModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:flutter/material.dart';
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

  bool isLoading = true; // Track if data is loading
  int userId = 0;
  double screenHeight = 0;
  double screenWidth = 0;
  final _idController = TextEditingController();

  String checkInAM = "00:00:00";
  String inAM = "--";
  String checkOutAM = "00:00:00";
  String outAM = "--";
  String checkInPM = "00:00:00";
  String inPM = "--";
  String checkOutPM = "00:00:00";
  String outPM = "--";
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
  Future today(todayStream) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final response = await http.post(
      Uri.parse('${Server.host}users/student/today.php'),
      body: {
        'id': userId,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now())
      },
    );
    print(DateFormat('yyyy-MM-dd').format(DateTime.now()));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final today = TodayModel.fromJson(data);

      setState(() {
        checkInAM = today.time_in_am;
        inAM = today.in_am;
        checkOutAM = today.time_out_am;
        outAM = today.out_am;
        checkInPM = today.time_in_pm;
        inPM = today.in_pm;
        checkOutPM = today.time_out_pm;
        outPM = today.out_pm;
      });
      // todayStream.add(today);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  Future<void> insertToday(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final estabId = widget.id;
    String defaultDATE = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String apiUrl = '${Server.host}users/student/insert_estab.php';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String jsonData =
        '{"student_id": "$userId", "estab_id": "$estabId","time_in_am":"$checkInAM","in_am":"$inAM", "time_out_am":"$checkOutAM","out_am":"$outAM","time_in_pm":"$checkInPM","in_pm":"$inPM","time_out_pm":"$checkOutPM","out_pm":"$outPM","date":"$defaultDATE"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    print(defaultDATE);
    today(_todayStream);
  }

  @override
  void initState() {
    super.initState();
    // sharedPref();
    today(_todayStream);
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

    return Column(
      children: [
        Stack(
          children: <Widget>[
            SizedBox(
              height: 80,
              width: double.maxFinite,
              child: Image.asset(
                "assets/images/green2.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      ClipRRect(
                        borderRadius: Style.borderRadius,
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'assets/images/estab.png',
                              height: 80,
                              width: 80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                DateFormat('hh:mm:ss a').format(DateTime.now()),
                style: TextStyle(
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth / 15,
                  color: Colors.black54,
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            // margin: const EdgeInsets.only(top: 12, bottom: 10),
            height: screenHeight / 3,
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black26,
            //       blurRadius: 10,
            //       offset: Offset(2, 2),
            //     ),
            //   ],
            //   borderRadius: BorderRadius.all(Radius.circular(20)),
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Time-In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        checkInAM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm ').format(
                                    DateFormat('HH:mm:ss').parse(checkInAM)) +
                                inAM,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Time-In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        checkInPM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm ').format(
                                    DateFormat('HH:mm:ss').parse(checkInPM)) +
                                inPM,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Time-Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        checkOutAM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm ').format(
                                    DateFormat('HH:mm:ss').parse(checkOutAM)) +
                                outAM,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Time-Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        checkOutPM == defaultValue
                            ? defaultT
                            : DateFormat('hh:mm ').format(
                                    DateFormat('HH:mm:ss').parse(checkOutPM)) +
                                outPM,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        checkInAM == defaultValue ||
                checkOutAM == defaultValue ||
                checkInPM == defaultValue ||
                checkOutPM == defaultValue
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Camera(
                            name: Session.email,
                          )));
                },
                child: Container(
                  decoration: Style.boxdecor,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Lottie.asset('assets/scan.json'),
                    ),
                  ),
                ),
              )
            :
            // ? Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 20),
            //     child: Container(
            //       // margin: const EdgeInsets.only(
            //       //   top: 20,
            //       //   bottom: 12,
            //       // ),
            //       child: Builder(
            //         builder: (context) {
            //           final GlobalKey<SlideActionState> key = GlobalKey();
            //           return SlideAction(
            //               text: checkInAM == defaultValue
            //                   ? "Slide to Time In"
            //                   : checkOutAM == defaultValue
            //                       ? "Slide to Time Out"
            //                       : checkInPM == defaultValue
            //                           ? "Slide to Time In"
            //                           : "Slide to Time Out",
            //               textStyle: TextStyle(
            //                 color: Colors.black54,
            //                 fontSize: screenWidth / 20,
            //                 fontFamily: "NexaRegular",
            //               ),
            //               outerColor: Colors.white,
            //               innerColor: checkInAM == defaultValue
            //                   ? Colors.green
            //                   : checkOutAM == defaultValue
            //                       ? Colors.orange
            //                       : checkInPM == defaultValue
            //                           ? Colors.green
            //                           : Colors.orange,
            //               key: key,
            //               onSubmit: () async {
            //                 final prefs = await SharedPreferences.getInstance();

            //                 checkInAM == "00:00:00"
            //                     ? setState(() async {
            //                         checkInAM = DateFormat('hh:mm a')
            //                             .format(DateTime.now());
            //                         inAM =
            //                             DateFormat('a').format(DateTime.now());
            //                         await insertToday(widget.id);
            //                         key.currentState!.reset();
            //                         // prefs.setString('timeINAM', checkInAM);
            //                       })
            //                     : checkOutAM == "00:00:00"
            //                         ? setState(() async {
            //                             checkOutAM = DateFormat('hh:mm a')
            //                                 .format(DateTime.now());
            //                             outAM = DateFormat('a')
            //                                 .format(DateTime.now());
            //                             await insertToday(widget.id);
            //                             key.currentState!.reset();
            //                             //  prefs.setString('timeOUTAM', checkOutAM);
            //                           })
            //                         : checkInPM == "00:00:00"
            //                             ? setState(() async {
            //                                 checkInPM = DateFormat('hh:mm a')
            //                                     .format(DateTime.now());
            //                                 inPM = DateFormat('a')
            //                                     .format(DateTime.now());
            //                                 await insertToday(widget.id);
            //                                 key.currentState!.reset();
            //                                 //  prefs.setString('timeINPM', checkInPM);
            //                               })
            //                             : setState(() async {
            //                                 checkOutPM = DateFormat('hh:mm a')
            //                                     .format(DateTime.now());
            //                                 outPM = DateFormat('a')
            //                                     .format(DateTime.now());
            //                                 await insertToday(widget.id);
            //                                 key.currentState!.reset();
            //                                 //  prefs.setString('timeOUTPM', checkOutPM);
            //                               });
            //               });
            //         },
            //       ),
            //     ),
            //   )
            Container(
                margin: const EdgeInsets.only(top: 20, bottom: 32),
                child: Text(
                  "You have completed this day!",
                  style: TextStyle(
                    fontFamily: "NexaRegular",
                    fontSize: screenWidth / 20,
                    color: Colors.black54,
                  ),
                ),
              ),
        // TextButton(
        //   child: const Text("Details"),
        //   onPressed: () => showReport(context),
        // )
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 20),
        //   child: ListTile(
        //     title: Text(checkInAM),
        //     trailing: Text(checkOutAM),
        //   ),
        // ),
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 20),
        //   child: ListTile(
        //     title: Text(checkInPM),
        //     trailing: Text(checkOutPM),
        //   ),
        // )
      ],
    );
  }
}
