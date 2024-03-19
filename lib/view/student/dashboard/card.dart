import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/home.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/controller/Leave.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashCard extends StatefulWidget {
  const DashCard(
      {super.key,
      required this.id,
      required this.name,
      required this.path,
      required this.refreshCallback});
  final String id;
  final String name;
  final String path;
  final VoidCallback refreshCallback;
  @override
  State<DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<DashCard> {
  String req = '';
  String hours = '';

  @override
  void initState() {
    super.initState();
    fetchGrandTotal();

    List<String> parts = Session.hours_required.split(':');
    String hours = parts[0];
    req = hours;
  }

  Future<void> fetchGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      // Replace 'your_php_script_url' with the actual URL of your PHP script
      final response = await http.post(
        Uri.parse('${Server.host}users/student/hours_rendered_only.php'),
        body: {'id': userId, 'estab_id': widget.id},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData['grand_total_hours_rendered']);
        // Extract the grand total hours rendered from the response
        setState(() {
          hours = responseData['grand_total_hours_rendered'];
        });
      } else {
        // Handle non-200 status code (e.g., display an error message)
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching grand total: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HoursRendered>(builder: (context, user, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Section(
                          ids: widget.id,
                          name: widget.name,
                        )));
                // : Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => Establishment(
                //           id: widget.id,
                //           name: widget.name,
                //         )));
                fetchGrandTotal();
              },
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.asset(
                      // widget.path == 'class'
                      //     ?
                      'assets/images/blue.jpg',
                      // : 'assets/images/green.jpg',
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.maxFinite,
                    ),
                  ),
                  Column(children: [
                    ListTile(
                      titleTextStyle:
                          Style.MontserratBold.copyWith(fontSize: 20),
                      iconColor: Colors.white,
                      title: Text(widget.name),
                      subtitle: Text(
                        // widget.path == 'class' ?
                        // "Section",
                        "OJT Establishment",
                        style: const TextStyle(color: Colors.white),
                      ),
                      // subtitle: Text("Supervisor"),
                    ),
                  ]),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Leave',
                            child: Text('Leave'),
                          ),
                        ];
                      },
                      onSelected: (String value) async {
                        if (value == 'Leave') {
                          await leaveClass(context, "room");
                          widget.refreshCallback();
                          print('Refresh Callback Triggered');
                        }
                      },
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Text(
                          "Overall hours rendered :",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Text(
                          hours + " / " + req + " hours",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
