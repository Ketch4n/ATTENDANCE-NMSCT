import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/controller/Delete.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/AccomplishmentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AdminViewAccomplishment extends StatefulWidget {
  const AdminViewAccomplishment({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<AdminViewAccomplishment> createState() =>
      _AdminViewAccomplishmentState();
}

class _AdminViewAccomplishmentState extends State<AdminViewAccomplishment> {
  final StreamController<List<AccomplishmentModel>> _textStreamController =
      StreamController<List<AccomplishmentModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  Future<void> _getTextReferences() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/admin/accomplishment.php'),
        body: {'email': widget.email, 'date': _yearMonth},
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
          title: const Text("Accomplishment"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints:
                kIsWeb ? BoxConstraints(maxWidth: screenWidth / 2) : null,
            child: Column(
              children: [
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    final month = await showMonthYearPicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2099),
                    );

                    if (month != null) {
                      setState(() {
                        _month = DateFormat('MMMM').format(month);
                        _yearMonth = DateFormat('yyyy-MM').format(month);
                      });
                    }
                    _getTextReferences();
                  },
                  child: Text(
                    _month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "NexaBold",
                      // fontSize: screenWidth / 15,
                    ),
                  ),
                ),
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
                            children: const [
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
                                            child: ListTile(
                                              title: Text(record.week),
                                              subtitle: Text(record.comment
                                                  .replaceAll('<br />', '')),
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
