import 'dart:async';
import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/auth/signup.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/EstabRoomModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/estab_insert_sched.dart';
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
  String defaultTime = "00:00:00";

  Future<void> fetchInterns(
      StreamController<List<EstabRoomModel>> internstreamController) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    setState(() {
      yourID = userId!;
    });
    final response = await http.post(
      Uri.parse('${Server.host}users/establishment/estab_room.php'),
      body: {
        'establishment_id': widget.ids,
        'email': Session.email,
        'role': Session.role
      },
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
            ListTile(
              title: Text(
                Session.role!,
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
            Session.role == "FACULTY"
                ? SizedBox()
                : ElevatedButton(
                    onPressed: () {
                      showAddDialog();
                    },
                    child: Text("Add Interns")),
            StreamBuilder<List<EstabRoomModel>>(
                stream: _internsStreamController.stream,
                builder: (context, snapshot) {
                  final List<EstabRoomModel>? interns = snapshot.data;
                  if (snapshot.hasData && interns != null) {
                    final Map<String, List<EstabRoomModel>> groupedInterns =
                        groupInternsByEmail(interns);
                    return Expanded(
                      child: ListView.builder(
                          itemCount: groupedInterns.length,
                          itemBuilder: (context, index) {
                            final String email =
                                groupedInterns.keys.elementAt(index);
                            final List<EstabRoomModel> internGroup =
                                groupedInterns[email]!;
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InternListItem(
                                email: email,
                                internGroup: internGroup,
                                defaultTime: defaultTime,
                                onSchedulePressed: (classmate) {
                                  _showAlertDialog(
                                    context,
                                    classmate,
                                    classmate.sched_id!,
                                    classmate.email,
                                    classmate.establishment_id,
                                    classmate.student_id,
                                  );
                                },
                                onAddSchedulePressed: (classmate) {
                                  // Add your logic to add a new schedule here
                                },
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

  Map<String, List<EstabRoomModel>> groupInternsByEmail(
      List<EstabRoomModel> interns) {
    final Map<String, List<EstabRoomModel>> groupedInterns = {};
    for (final intern in interns) {
      if (!groupedInterns.containsKey(intern.email)) {
        groupedInterns[intern.email] = [];
      }
      groupedInterns[intern.email]!.add(intern);
    }
    return groupedInterns;
  }

  void _showAlertDialog(BuildContext context, EstabRoomModel classmate,
      int dataid, String name, int estabID, int studentID) {
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
                estab: classmate,
                name: name,
                dataID: dataid,
                id: estabID,
                student: studentID,
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

class InternListItem extends StatelessWidget {
  final String email;
  final List<EstabRoomModel> internGroup;
  final String defaultTime;
  final Function(EstabRoomModel) onSchedulePressed;
  final Function(EstabRoomModel) onAddSchedulePressed;

  const InternListItem({
    Key? key,
    required this.email,
    required this.internGroup,
    required this.defaultTime,
    required this.onSchedulePressed,
    required this.onAddSchedulePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(email, style: const TextStyle(fontSize: 18)),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        constraints:
                            const BoxConstraints(maxHeight: 700, maxWidth: 400),
                        child: InsertSched(
                          id: internGroup.first.establishment_id,
                          student: internGroup.first.student_id,
                          onDialogClose: () {},
                        )),
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      subtitle: Column(
        children: internGroup.map((classmate) {
          return Row(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${classmate.lname}, ${classmate.fname}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                    classmate.email,
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text("Arrival-AM "),
                  Text(classmate.in_am == defaultTime || classmate.in_am == null
                      ? "NOT-SET"
                      : classmate.in_am!)
                ],
              ),
              Column(
                children: [
                  Text(" Departure-AM "),
                  Text(classmate.out_am == defaultTime ||
                          classmate.out_am == null
                      ? "NOT-SET"
                      : classmate.out_am!),
                ],
              ),
              Column(
                children: [
                  Text(" Arrival-PM "),
                  Text(classmate.in_pm == defaultTime || classmate.in_pm == null
                      ? "NOT-SET"
                      : classmate.in_pm!),
                ],
              ),
              Column(
                children: [
                  Text(" Departure-PM"),
                  Text(classmate.out_pm == defaultTime ||
                          classmate.out_pm == null
                      ? "NOT-SET"
                      : classmate.out_pm!),
                ],
              ),
              IconButton(
                onPressed: () {
                  onSchedulePressed(classmate);
                },
                icon: const Icon(Icons.schedule),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
