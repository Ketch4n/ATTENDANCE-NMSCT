import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/controller/Delete.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AccomplishmentDetails extends StatefulWidget {
  const AccomplishmentDetails({super.key, required this.id});
  final String id;

  @override
  State<AccomplishmentDetails> createState() => _AccomplishmentDetailsState();
}

class _AccomplishmentDetailsState extends State<AccomplishmentDetails> {
  final StreamController<List<AccomplishmentModel>> _textStreamController =
      StreamController<List<AccomplishmentModel>>();
  bool isLoading = true;

  Future<void> _getTextReferences() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/accomplishment.php'),
        body: {'email': Session.email, 'section_id': widget.id, 'date': date},
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
    return Scaffold(
      appBar: AppBar(
        title: Text(date),
        centerTitle: true,
      ),
      body: SizedBox(
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
                return Center(
                  child: Text("No data available."),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: text.length,
                  itemBuilder: (context, index) {
                    final AccomplishmentModel record = text[index];
                    return TimelineTile(
                        indicatorStyle: IndicatorStyle(
                          width: 15,
                          color: Colors.green,
                          padding: const EdgeInsets.only(left: 20.0, bottom: 5),
                        ),
                        isFirst: index == 0,
                        isLast: index == snapshot.data!.length - 1,
                        endChild: Stack(children: [
                          GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Accomplishment'),
                                    content: const Text(
                                        'Are you sure you want to delete this record?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () async {
                                          await deleteAccomplishment(
                                              context, record.id);
                                          Navigator.of(context).pop();
                                          _getTextReferences();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                                elevation: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Expanded(
                                  child: Container(
                                    width: double.maxFinite,
                                    decoration: Style.boxdecor.copyWith(
                                        borderRadius: Style.defaultradius),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(record.comment
                                          .replaceAll('<br />', '')),
                                    ),
                                  ),
                                )),
                          ),
                        ]));
                  },
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
