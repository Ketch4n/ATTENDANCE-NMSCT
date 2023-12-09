import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/accomplishment/view.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/model/AccomplishmentTodayModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/metadata/view.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAccomplishmentIndex extends StatefulWidget {
  const AdminAccomplishmentIndex({super.key, required this.id});
  final String id;

  @override
  State<AdminAccomplishmentIndex> createState() =>
      _AdminAccomplishmentIndexState();
}

class _AdminAccomplishmentIndexState extends State<AdminAccomplishmentIndex> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
      GlobalKey<RefreshIndicatorState>();

  final StreamController<List<AccomplishmentTodayModel>> _textStreamController =
      StreamController<List<AccomplishmentTodayModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _getTextReferences() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/admin/accomplishment.php'),
        body: {'section_id': widget.id, 'date': date},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<AccomplishmentTodayModel> text = data
            .map((textData) => AccomplishmentTodayModel.fromJson(textData))
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

  @override
  void initState() {
    super.initState();
    _getTextReferences();
  }

  @override
  dispose() {
    super.dispose();
    _getTextReferences;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicator,
      onRefresh: _getTextReferences,
      child: Scaffold(
        body: Column(
          children: [
            StreamBuilder<List<AccomplishmentTodayModel>>(
              stream: _textStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  final List<AccomplishmentTodayModel> text = snapshot.data!;

                  if (text.isEmpty) {
                    return Expanded(
                      child: ListView(
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
                      ),
                    );
                  }

                  return Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing:
                              8.0, // You can adjust the spacing between items
                          runSpacing:
                              8.0, // You can adjust the spacing between lines
                          children: text.map((record) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminViewAccomplishment(
                                      email: record.email,
                                      section_id: widget.id,
                                      date: record.date,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.green,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text("Date: ${record.date}"),
                                      SizedBox(height: 4.0),
                                      Text(record.email),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                  );
                } else {
                  return Expanded(
                    child: CardPageSkeleton(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
