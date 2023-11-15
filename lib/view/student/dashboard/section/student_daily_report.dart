import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/accomplishment.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/widgets/header.dart';
import 'package:attendance_nmsct/view/student/dashboard/upload.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class StudentDailyReport extends StatefulWidget {
  const StudentDailyReport({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<StudentDailyReport> createState() => _StudentDailyReportState();
}

class _StudentDailyReportState extends State<StudentDailyReport> {
  List<Reference> _imageReferences = [];
  final StreamController<AccomplishmentModel> _userStreamController =
      StreamController<AccomplishmentModel>();

  bool isLoading = true; // Track if data is loading
  double screenHeight = 0;
  double screenWidth = 0;
  int userId = 0;
  final TextEditingController _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getImageReferences();
    _getTextReferences();
  }

  @override
  dispose() {
    super.dispose();
    _getTextReferences();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final email = prefs.getString('userEmail');
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final folderName =
        'face_data/$section/$email/$date'; // Specify your folder name

    try {
      final listResult = await storage.ref(folderName).list();
      final items = listResult.items;

      // Filter items based on the name containing "datetoday"
      // final datetodayItems = items.where((item) => item.name.contains(
      //     date)); // You may need to adjust the condition based on your file naming convention
      setState(() {
        _imageReferences = items.toList();
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

  Future<void> _getTextReferences() async {
    // final prefs = await SharedPreferences.getInstance();
    // final userEmail = prefs.getString('userEmail');
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/accomplishment.php'),
        body: {'email': Session.email, 'date': date},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final user = AccomplishmentModel.fromJson(data);

        // Add the user data to the stream
        _userStreamController.add(user);
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
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SectionHeader(name: widget.name),
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () async {
              // await Navigator.of(context).push(
              //   MaterialPageRoute(
              //       builder: ((context) => Camera(name: widget.name))),
              // );
              // _getImageReferences();
              await bottomsheetUpload(
                context,
                widget.ids,
                widget.name,
                comment: _commentController,
                refreshCallback: _getImageReferences,
              );
            },
            child: Container(
              height: 70,
              width: double.maxFinite,
              decoration:
                  Style.boxdecor.copyWith(borderRadius: Style.defaultradius),
              child: Align(
                alignment: Alignment.center,
                child: ListTile(
                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: Style.borderRadius,
                        child: Image.asset(
                          "assets/images/admin.png",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Daily Report (meta data)",
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.upload),
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          const Expanded(
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
          const Expanded(
            child: Center(
              child: Text(
                'No data available.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        else
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _imageReferences.length,
                    itemBuilder: (context, index) {
                      final imageRef = _imageReferences[index];
                      final imageName = imageRef.name; // Get the image name
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 55,
                              width: double.maxFinite,
                              decoration: Style.boxdecor
                                  .copyWith(borderRadius: Style.defaultradius),
                              child: ListTile(
                                title: Text(
                                  imageName,
                                  style: TextStyle(fontSize: screenWidth / 25),
                                ),
                                // subtitle: FutureBuilder(
                                //   future: imageRef.getMetadata(),
                                //   builder: (context, snapshot) {
                                //     if (snapshot.connectionState ==
                                //         ConnectionState.done) {
                                //       if (snapshot.hasData) {
                                //         final metadata =
                                //             snapshot.data as FullMetadata;
                                //         final location =
                                //             metadata.customMetadata!['Location'] ??
                                //                 'N/A';
                                //         return Text('Location: $location');
                                //       }
                                //     }
                                //     return const Text('Fetching metadata...');
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
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Image'),
                                        content: const Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              deleteImage(imageRef);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder<AccomplishmentModel>(
                    stream: _userStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        AccomplishmentModel user = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.date,
                              style: Style.profileText.copyWith(fontSize: 18),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    }),
              ],
            ),
          ),
      ],
    );
  }
}
