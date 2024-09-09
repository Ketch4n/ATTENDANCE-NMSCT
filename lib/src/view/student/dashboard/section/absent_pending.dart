import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/controller/Insert.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/data/mail/smtp.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/AbsentModel.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AbsentPendingTab extends StatefulWidget {
  const AbsentPendingTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AbsentPendingTab> createState() => _AbsentPendingTabState();
}

class _AbsentPendingTabState extends State<AbsentPendingTab> {
  final StreamController<List<AbsentModel>> _absentController =
      StreamController<List<AbsentModel>>();
  Future<void> streamAccomplishemnt(absentController) async {
    const String studentAbsent = "users/student/view_absent.php";
    const String estabAbsent = "users/establishment/view_all_absent.php";
    final query = Session.role == "INTERN" ? studentAbsent : estabAbsent;
    try {
      final response = await http.post(
        Uri.parse('${Server.host}$query'),
        body: {
          'student_id': Session.id,
          'section_id': widget.ids,
          'status': 'Pending'
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        final List<AbsentModel> absent = jsonList
            .map((absentData) => AbsentModel.fromJson(absentData))
            .toList();
        absentController.add(absent);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  DateTime _date = DateTime.now();
  final _reason = TextEditingController();

  Future _showDatePicker() async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        setState(() {
          _date = value;
        });
        _showCustomModal();
      }
    });
  }

  void _showCustomModal() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reason of absent :'),
          content: TextField(
            controller: _reason,
            decoration:
                const InputDecoration(labelText: 'brief as possible...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await insertAbsent(context, widget.ids, _reason.text, _date);
                streamAccomplishemnt(_absentController);
                _reason.clear();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void action(absent) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Select Option'),
          content: const Text('Approved or Declined'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                const String stats = "Declined";

                Navigator.of(context).pop();
                _actionDone(absent, stats);
              },
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                const String stats = "Approved";

                _actionDone(absent, stats);

                Navigator.of(context).pop();
              },
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(absent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Absent?'),
          content: const Text('Are you sure you want to cancel this absent ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAbsent(absent);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _actionDone(AbsentModel absent, String stats) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/update_absent.php'),
        body: {'absent_id': absent.id, 'status': stats},
      );
      if (response.statusCode == 200) {
        print("NOW OR NEVER :${absent.id}");
        const purpose = "Absent";

        // If deletion is successful, refresh the list
        streamAccomplishemnt(_absentController);
        sendEmailNotification(purpose, stats, absent.email!);
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _deleteAbsent(AbsentModel absent) async {
    try {
      print("ID${absent.id}");
      // Perform deletion logic here, such as making an HTTP request to delete the record from the server
      final response = await http.post(
        Uri.parse('${Server.host}users/student/delete_absent.php'),
        body: {
          'absent_id': absent.id,
        },
      );
      if (response.statusCode == 200) {
        // If deletion is successful, refresh the list
        streamAccomplishemnt(_absentController);
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    streamAccomplishemnt(_absentController);
  }

  @override
  void dispose() {
    super.dispose();
    _absentController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Session.role == "Intern"
          ? FloatingActionButton(
              onPressed: () {
                _showDatePicker();
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AbsentModel>>(
              stream: _absentController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  final List<AbsentModel> data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Pending absent request',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final AbsentModel absent = data[index];
                        return Container(
                          padding: EdgeInsets.only(
                            bottom:
                                index == snapshot.data!.length - 1 ? 70.0 : 0,
                          ),
                          child: TimelineTile(
                            isFirst: index == 0,
                            isLast: index == snapshot.data!.length - 1,
                            alignment: TimelineAlign.start,
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              color: absent.status == 'Pending'
                                  ? Colors.blue
                                  : absent.status == 'Approved'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            endChild: GestureDetector(
                              onLongPress: () {
                                Session.role == "INTERN"
                                    ? _showDeleteConfirmationDialog(absent)
                                    : action(absent);
                                print(absent);
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Text("Absent: ${absent.date}"),
                                        Text(
                                          "  (${absent.status})",
                                          style: TextStyle(
                                            color: absent.status == 'Pending'
                                                ? Colors.blue
                                                : absent.status == 'Approved'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        )
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(Session.role == "Intern"
                                              ? ""
                                              : "From : ${absent.lname!}"),
                                          Text(Session.role == "Intern"
                                              ? ""
                                              : absent.email!),
                                          Text(
                                              "Reason of absent: ${absent.reason}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Expanded(
                    child: CardPageSkeleton(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
