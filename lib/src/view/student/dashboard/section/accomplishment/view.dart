import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/controller/Delete.dart';
import 'package:attendance_nmsct/src/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/model/AccomplishmentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AccomplishmentView extends StatefulWidget {
  const AccomplishmentView({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AccomplishmentView> createState() => _AccomplishmentViewState();
}

class _AccomplishmentViewState extends State<AccomplishmentView> {
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
        body: {'email': Session.email, 'section_id': widget.ids, 'date': date},
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

  Stream<List<AccomplishmentModel>> streamAccomplishemnt() async* {
    while (true) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await http.post(
        Uri.parse('${Server.host}users/student/accomplishment.php'),
        body: {'email': Session.email, 'section_id': widget.ids, 'date': date},
      );
      // print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        yield jsonList
            .map((json) => AccomplishmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }

      await Future.delayed(
          const Duration(seconds: 2)); // Adjust the refresh rate as needed
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _getTextReferences,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await accomplishmentReport(
                context, widget.ids, _commentController, _getTextReferences);
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
                "${DateFormat('MMM dd, yyyy').format(DateTime.now())} - TODAY"),
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
                                color: Colors.green, // Adjust color as needed
                              ),
                              endChild: Container(
                                // padding: EdgeInsets.only(
                                //     bottom: index == snapshot.data!.length - 1
                                //         ? 80.0
                                //         : 0),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
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
                                                child: Text(DateFormat('hh:mm ')
                                                    .format(
                                                        DateFormat('HH:mm:ss')
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
    );
  }
}
