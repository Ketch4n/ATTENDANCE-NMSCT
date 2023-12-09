import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/controller/Delete.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AdminViewAccomplishment extends StatefulWidget {
  const AdminViewAccomplishment(
      {super.key,
      required this.email,
      required this.section_id,
      required this.date});
  final String email;
  final String section_id;
  final String date;
  @override
  State<AdminViewAccomplishment> createState() =>
      _AdminViewAccomplishmentState();
}

class _AdminViewAccomplishmentState extends State<AdminViewAccomplishment> {
  final StreamController<List<AccomplishmentModel>> _textStreamController =
      StreamController<List<AccomplishmentModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _commentController = TextEditingController();

  Future<void> _getTextReferences() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/accomplishment.php'),
        body: {
          'email': widget.email,
          'section_id': widget.section_id,
          'date': date
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<AccomplishmentModel> text = data
            .map((textData) => AccomplishmentModel.fromJson(textData))
            .toList();

        // Add the list to the stream
        _textStreamController.add(text);
      } else {
        // Handle HTTP error
        print('Failed to load data. HTTP status code: ${response.statusCode}');
        // You might want to display an error message to the user
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // You might want to display an error message to the user
    }
  }

  Future<void> deleteImage(AccomplishmentModel record) async {
    // Show a confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this accomplishment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled deletion
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      // User confirmed deletion
      try {
        await deleteAccomplishment(context, record.id);

        _getTextReferences();
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getTextReferences();
  }

  @override
  dispose() {
    super.dispose();

    _textStreamController.close();
  }

  double screenHeight = 0;
  double screenWidth = 0;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _getTextReferences,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Accomplishment"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints:
                kIsWeb ? BoxConstraints(maxWidth: screenWidth / 2) : null,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<AccomplishmentModel>>(
                    stream: _textStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else if (snapshot.hasData) {
                        final List<AccomplishmentModel> text = snapshot.data!;

                        if (text.isEmpty) {
                          return ListView(
                            scrollDirection: Axis.vertical,
                            children: [
                              Duck(),
                              Center(
                                child: Text(
                                  'No data uploaded today !',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: text.length,
                            itemBuilder: (context, index) {
                              final AccomplishmentModel record = text[index];
                              final time = record.time;
                              return Container(
                                padding: EdgeInsets.only(
                                    bottom: index == snapshot.data!.length - 1
                                        ? 70.0
                                        : 0),
                                child: TimelineTile(
                                  isFirst: index == 0,
                                  isLast: index == snapshot.data!.length - 1,
                                  alignment: TimelineAlign.start,
                                  indicatorStyle: const IndicatorStyle(
                                    width: 20,
                                    color:
                                        Colors.green, // Adjust color as needed
                                  ),
                                  endChild: Container(
                                    // padding: EdgeInsets.only(
                                    //     bottom: index == snapshot.data!.length - 1
                                    //         ? 80.0
                                    //         : 0),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                    child: GestureDetector(
                                      onLongPress: () =>
                                          // _showUpdateDeleteModal(record),
                                          deleteImage(record),
                                      child: Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                Text(record.comment
                                                    .replaceAll('<br />', '')),
                                                Positioned(
                                                    right: 0,
                                                    child: Text(
                                                        DateFormat('hh:mm ')
                                                            .format(DateFormat(
                                                                    'HH:mm:ss')
                                                                .parse(time))))
                                              ],
                                            )),
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
          ),
        ),
      ),
    );
  }
}
