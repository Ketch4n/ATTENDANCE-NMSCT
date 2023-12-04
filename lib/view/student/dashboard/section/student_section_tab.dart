import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/controller/Insert.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/model/AbsentModel.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:timeline_tile/timeline_tile.dart';

class StudentSectionTab extends StatefulWidget {
  const StudentSectionTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<StudentSectionTab> createState() => _StudentSectionTabState();
}

class _StudentSectionTabState extends State<StudentSectionTab> {
  Stream<List<AbsentModel>> streamAccomplishemnt() async* {
    while (true) {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/view_absent.php'),
        body: {'student_id': Session.id, 'section_id': widget.ids},
      );
      // print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        yield jsonList.map((json) => AbsentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data');
      }

      await Future.delayed(
          const Duration(seconds: 2)); // Adjust the refresh rate as needed
    }
  }

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        // Save the selected date
        setState(() {
          _date = value;
        });

        // Show a custom modal with a text field
        _showCustomModal();
      }
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        _time = value!;
      });
    });
  }

  final _reason = TextEditingController();

  void _showCustomModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reason of absent :'),
          content: TextField(
            controller: _reason,
            // You can customize the text field as needed
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
              onPressed: () {
                // Handle the text field value as needed
                // You can access it using a controller or directly from the TextField widget

                insertAbsent(context, widget.ids, _reason.text, _date, _time);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    streamAccomplishemnt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDatePicker();
          },
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<List<AbsentModel>>(
            stream: streamAccomplishemnt(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                final List<AbsentModel> data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(
                    child: Text("NO RECORD OF ABSENCES"),
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
                              bottom: index == snapshot.data!.length - 1
                                  ? 70.0
                                  : 0),
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
                              // onLongPress: () => _showUpdateDeleteModal(record),
                              child: Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      // leading: Text(
                                      //     "Absent Date: " + absent.date),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                            "Reason of absent: ${absent.reason}"),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              } else {
                return Expanded(
                  child: CardPageSkeleton(),
                );
              }
            }));
  }
}
