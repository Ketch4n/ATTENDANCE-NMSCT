import 'dart:async';
import 'dart:convert';

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/AccomplishmentModel.dart';
import 'package:attendance_nmsct/src/view/student/dashboard/section/metadata/metadata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Record extends StatefulWidget {
  const Record(
      {super.key,
      required this.ids,
      required this.name,
      required this.date,
      required this.section});
  final String ids;
  final String name;
  final String date;
  final String section;
  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
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

    _textStreamController.close();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = kIsWeb ? widget.name : widget.name;
    final file = widget.date;
    final email = kIsWeb ? widget.ids : prefs.getString('userEmail');
    final folderName = 'face_data/$section/$email/$file';

    try {
      final listResult = await storage.ref(folderName).list();
      final items = listResult.items;

      // Map each reference to its download URL asynchronously
      final urls = items.map((ref) => ref.getDownloadURL()).toList();

      setState(() {
        _imageReferences = items.toList();
        _imageUrls = urls;
        isLoading = false; // Data has loaded
      });
    } catch (e) {
      print('Error listing files: $e');
      setState(() {
        isLoading = false; // Data has failed to load
      });
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
        Uri.parse('${Server.host}users/student/accomplishment.php'),
        body: {
          'email': Session.email,
          'section_id': widget.ids,
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
        title: Text(widget.date),
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
                  // scrollDirection: Axis.horizontal,
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
        ],
      ),
    );
  }
}
