import 'package:attendance_nmsct/view/student/dashboard/section/metadata/camera.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AdminViewMetaData extends StatefulWidget {
  const AdminViewMetaData(
      {super.key,
      required this.email,
      required this.date,
      required this.section});
  final String email;
  final String date;
  final String section;
  @override
  State<AdminViewMetaData> createState() => _AdminViewMetaDataState();
}

class _AdminViewMetaDataState extends State<AdminViewMetaData> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Reference> _imageReferences = [];
  List _imageUrls = [];

  bool isLoading = true; // Track if data is loading
  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final email = widget.email;
    final date = widget.date;
    final section = widget.section;

    final folderName =
        'face_data/$section/$email/$date'; // Specify your folder name

    try {
      final listResult = await storage.ref(folderName).listAll();
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
    // Show a confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this image?'),
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
        await imageRef.delete();

        _getImageReferences(); // Refresh the list after deletion
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getImageReferences();
  }

  double screenHeight = 0;
  double screenWidth = 0;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _getImageReferences,
      child: Scaffold(
        appBar: AppBar(
          title: Text("MetaData"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints:
                kIsWeb ? BoxConstraints(maxWidth: screenWidth / 2) : null,
            child: Column(
              children: [
                if (isLoading)
                  Expanded(
                    child: CardPageSkeleton(),
                  )
                else if (_imageReferences.isEmpty)
                  Expanded(
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
                  ))
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: _imageReferences.length,
                        itemBuilder: (context, index) {
                          final imageRef = _imageReferences[index];

                          final imageName = imageRef.name;

                          return Container(
                            padding: EdgeInsets.only(
                                bottom: index == _imageReferences.length - 1
                                    ? 70.0
                                    : 0),
                            child: TimelineTile(
                              isFirst: index == 0,
                              isLast: index == _imageReferences.length - 1,
                              alignment: TimelineAlign.start,
                              indicatorStyle: const IndicatorStyle(
                                width: 20,
                                color: Colors.blue, // Adjust color as needed
                              ),
                              endChild: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: GestureDetector(
                                  onLongPress: () => deleteImage(imageRef),
                                  child: Card(
                                    child: ListTile(
                                      leading: FutureBuilder(
                                        future: _imageUrls[index],
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return Image.network(
                                              snapshot.data.toString(),
                                              width:
                                                  50, // Adjust width as needed
                                              height:
                                                  50, // Adjust height as needed
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      ),
                                      title: Text(
                                        imageName,
                                        // style:
                                        //     TextStyle(fontSize: screenWidth / 25),
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
