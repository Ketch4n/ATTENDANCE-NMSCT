import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:http/http.dart' as http;

class AdminRecord extends StatefulWidget {
  const AdminRecord(
      {super.key,
      required this.email,
      required this.section_id,
      required this.date});
  final String email;
  final String section_id;
  final String date;
  @override
  State<AdminRecord> createState() => _AdminRecordState();
}

class _AdminRecordState extends State<AdminRecord> {
  List<Reference> _imageReferences = [];
  List _imageUrls = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getImageReferences();
    _getTextReferences();
  }

  @override
  dispose() {
    super.dispose();
    _getImageReferences;
    _textStreamController.close;
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;

    final section = widget.section_id;
    final file = widget.date;

    // final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final folderName = 'face_data/$section/$file'; // Specify your folder name

    try {
      final listResult = await storage.ref(folderName).list();
      final items = listResult.items;

      // Filter items based on the name containing "datetoday"
      // final datetodayItems = items.where((item) => item.name.contains(
      //     date)); // You may need to adjust the condition based on your file naming convention
      setState(() {
        _imageReferences = items.toList();
        _imageUrls = _imageReferences.map((ref) {
          return ref.getDownloadURL();
        }).toList();
        isLoading = false; // Data has loaded
      });
    } catch (e) {
      print('Error listing files: $e');
      isLoading = false; // Data has failed to load
    }
  }

  Future<void> deleteImage(Reference imageRef) async {
    try {
      await imageRef.delete();
      _getImageReferences(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  final StreamController<List<AccomplishmentModel>> _textStreamController =
      StreamController<List<AccomplishmentModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _getTextReferences() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/admin/monthly_accomplishment.php'),
        body: {
          'email': widget.email,
          'section_id': widget.section_id,
          'date': widget.date
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Record"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isLoading)
            const Flexible(
              flex: 1,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          //  Expanded(
          //   child: CardListSkeleton(
          //     isCircularImage: true,
          //     isBottomLinesActive: true,
          //     length: 1,
          //   ),
          // )
          else if (_imageReferences.isEmpty)
            const Flexible(
              flex: 1,
              child: Center(
                child: Text(
                  'No data available.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            Flexible(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageReferences.length,
                  itemBuilder: (context, index) {
                    final imageRef = _imageReferences[index];
                    final imageName = imageRef.name; // Get the image name
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 3,
                        ),
                        decoration: Style.boxdecor
                            .copyWith(borderRadius: Style.radius12),
                        child: ListTile(
                          title: FutureBuilder(
                            future: _imageUrls[index],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Image.network(
                                  snapshot.data.toString(),
                                  width: 100, // Adjust width as needed
                                  height: 100, // Adjust height as needed
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          // subtitle: FutureBuilder(
                          //   future: imageRef.getMetadata(),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState ==
                          //         ConnectionState.done) {
                          //       if (snapshot.hasData) {
                          //         final metadata = snapshot.data as FullMetadata;
                          //         final location =
                          //             metadata.customMetadata!['Location'] ??
                          //                 'N/A';
                          //         return Text('Location: $location');
                          //       }
                          //     }
                          //     return const Text('Fetching metadata...');
                          //   },
                          // ),
                          // trailing: IconButton(
                          //   icon: const Icon(Icons.delete),
                          //   onPressed: () {
                          //     showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: const Text('Delete Image'),
                          //           content: const Text(
                          //               'Are you sure you want to delete this image?'),
                          //           actions: <Widget>[
                          //             TextButton(
                          //               child: const Text('Cancel'),
                          //               onPressed: () {
                          //                 Navigator.of(context).pop();
                          //               },
                          //             ),
                          //             TextButton(
                          //               child: const Text('Delete'),
                          //               onPressed: () {
                          //                 deleteImage(imageRef);
                          //                 Navigator.of(context).pop();
                          //               },
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //   },
                          // ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Meta_Data(image: imageRef),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Flexible(
            flex: 4,
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
                    return const Center(
                      child: Text("No Accomplishment Report"),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: text.length,
                        itemBuilder: (context, index) {
                          final AccomplishmentModel record = text[index];
                          final time = record.time;
                          final date = record.date;
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
                                  // onLongPress: () => _showUpdateDeleteModal(record),
                                  child: Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: Text(record.comment
                                              .replaceAll('<br />', '')),
                                          trailing: Column(
                                            children: [
                                              Text(DateFormat('MM/dd/yy ')
                                                  .format(
                                                      DateFormat('yyyy-MM-dd')
                                                          .parse(date))),
                                              Text(DateFormat('hh:mm ').format(
                                                  DateFormat('HH:mm:ss')
                                                      .parse(time))),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return Expanded(
                    child: CardPageSkeleton(),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
