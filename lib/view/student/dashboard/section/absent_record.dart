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

class AbsentRecordTab extends StatefulWidget {
  const AbsentRecordTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AbsentRecordTab> createState() => _AbsentRecordTabState();
}

class _AbsentRecordTabState extends State<AbsentRecordTab> {
  final StreamController<List<AbsentModel>> _absentController =
      StreamController<List<AbsentModel>>();
  Future<void> streamAccomplishemnt(_absentController) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/view_absent.php'),
        body: {
          'student_id': Session.id,
          'section_id': widget.ids,
          'status': 'Record'
        },
      );
      // print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        // yield jsonList.map((json) => AbsentModel.fromJson(json)).toList();
        final List<AbsentModel> absent = jsonList
            .map((absentData) => AbsentModel.fromJson(absentData))
            .toList();
        _absentController.add(absent); // Add data to the stream
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // You might want to display an error message to the user
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
                    return Center(
                      child: Text(
                        'No records',
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
                                                color:
                                                    absent.status == 'Pending'
                                                        ? Colors.blue
                                                        : absent.status ==
                                                                'Approved'
                                                            ? Colors.green
                                                            : Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
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
              }),
        ),
      ],
    ));
  }
}
