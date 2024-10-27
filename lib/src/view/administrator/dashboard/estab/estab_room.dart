import 'dart:async';
import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/auth/signup.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/EstabRoomModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/estab_room_unregstudents.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/estab_sched.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class EstabRoom extends StatefulWidget {
  const EstabRoom({super.key, required this.ids});
  final String ids;

  @override
  State<EstabRoom> createState() => _EstabRoomState();
}

class _EstabRoomState extends State<EstabRoom> {
  final StreamController<List<EstabRoomModel>> _internsStreamController =
      StreamController<List<EstabRoomModel>>();

  @override
  void initState() {
    super.initState();
    fetchInterns(_internsStreamController);
  }

  @override
  void dispose() {
    super.dispose();
    _internsStreamController.close();
  }

  String yourID = "";

  Future<void> fetchInterns(
      StreamController<List<EstabRoomModel>> internstreamController) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    setState(() {
      yourID = userId!;
    });
    final response = await http.post(
      Uri.parse('${Server.host}users/establishment/estab_room.php'),
      body: {'establishment_id': widget.ids},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<EstabRoomModel> interns = data
          .map((classmateData) => EstabRoomModel.fromJson(classmateData))
          .toList();

      internstreamController.add(interns);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> showAddDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student Intern'),
          content:
              const Text('Manually join the student in this establishment'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UnregUsers(ids: widget.ids)));
                fetchInterns(_internsStreamController);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Auth()));
              },
              icon: Icon(Icons.home))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const ListTile(
              title: Text(
                "Administrator",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontFamily: "MontserratBold"),
              ),
              subtitle: Divider(
                color: Colors.blue,
                thickness: 2,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  ClipRRect(
                      borderRadius: Style.radius50,
                      child: Image.asset(
                        "assets/images/estab.png",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${Session.fname} (You)",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                        Session.email ?? "", // Handle potential null value
                        style: const TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const ListTile(
              title: Text(
                "Interns",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontFamily: "MontserratBold"),
              ),
              subtitle: Divider(
                color: Colors.blue,
                thickness: 2,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  showAddDialog();
                },
                child: const Icon(Icons.add)),
            StreamBuilder<List<EstabRoomModel>>(
                stream: _internsStreamController.stream,
                builder: (context, snapshot) {
                  final List<EstabRoomModel>? interns = snapshot.data;
                  if (snapshot.hasData && interns != null) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: interns.length,
                          itemBuilder: (context, index) {
                            final EstabRoomModel classmate = interns[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: Style.radius50,
                                        child: Image.asset(
                                          "assets/images/admin.png",
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${classmate.lname}, ${classmate.fname}',
                                            style:
                                                const TextStyle(fontSize: 18)),
                                        Text(
                                          classmate.email,
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text("Arrival-AM "),
                                        Text(classmate.in_am ?? "NOT-SET"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(" Departure-AM "),
                                        Text(classmate.out_am ?? "NOT-SET"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(" Arrival-PM "),
                                        Text(classmate.in_pm ?? "NOT-SET"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(" Departure-PM"),
                                        Text(classmate.out_pm ?? "NOT-SET"),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showAlertDialog(
                                          context,
                                          classmate.email,
                                          classmate.uid,
                                        );
                                      },
                                      icon: const Icon(Icons.schedule),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return const Center(child: Text("NO STUDENTS"));
                  }
                }),
          ],
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String name, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              constraints: const BoxConstraints(maxHeight: 700, maxWidth: 400),
              child: ViewSched(
                name: name,
                id: id,
                onDialogClose: () {
                  // Refresh the data when the dialog is closed
                  fetchInterns(_internsStreamController);
                },
              )),
        );
      },
    );
  }

  Future<void> bottomSheet() async {
    showAdaptiveActionSheet(
        context: context,
        title: const Text('Add Interns'),
        androidBorderRadius: 20,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: const Text(
                'Student',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "MontserratBold"),
              ),
              onPressed: (context) {
                const String purpose = 'Register';
                Navigator.of(context).pop(false);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Signup(
                          purpose: purpose,
                          reload: () {
                            setState(() {});
                          },
                        )));
              }),
        ]);
  }
}
