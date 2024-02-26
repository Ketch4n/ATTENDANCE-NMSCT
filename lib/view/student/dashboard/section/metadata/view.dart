import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:attendance_nmsct/controller/Delete.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/accomplishment/insert.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

class MetaDataIndex extends StatefulWidget {
  const MetaDataIndex({Key? key, required this.name, required this.ids})
      : super(key: key);
  final String name;
  final String ids;

  @override
  State<MetaDataIndex> createState() => _MetaDataIndexState();
}

class _MetaDataIndexState extends State<MetaDataIndex> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Reference> _imageReferences = [];
  List _imageUrls = [];
  final TextEditingController _commentController = TextEditingController();
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isLoading = false;
  final StreamController<List<AccomplishmentModel>> _textStreamController =
      StreamController<List<AccomplishmentModel>>();

  @override
  void initState() {
    super.initState();
    _getImageReferences();
    _getTextReferences();
  }

  @override
  void dispose() {
    super.dispose();
    _textStreamController.close();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final email = prefs.getString('userEmail');
    final folderName = 'face_data/$section/$email/$date';

    try {
      final listResult = await storage.ref(folderName).list();
      final items = listResult.items;

      setState(() {
        _imageReferences = items.toList();
        _imageUrls =
            _imageReferences.map((ref) => ref.getDownloadURL()).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error listing files: $e');
      isLoading = false;
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final prefs = await SharedPreferences.getInstance();
      final section = widget.name;
      final email = prefs.getString('userEmail');
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final folderName = 'face_data/$section/$email/$date';

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef =
          storage.ref().child('$folderName/$fileName.jpg');
      await storageRef.putFile(imageFile);

      _getImageReferences();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _getTextReferences() async {
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
        _textStreamController.add(text);
      } else {
        print('Failed to load data. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteText(AccomplishmentModel record) async {
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

  Future<void> _deleteImage(Reference imageRef) async {
    // Show confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      // User confirmed deletion
      try {
        await imageRef.delete();
        // Remove the deleted image reference from the list
        setState(() {
          _imageReferences.remove(imageRef);
        });
        print('Image deleted successfully');
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picker = ImagePicker();
          final pickedFile = await showDialog<PickedFile>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select Image Source'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Take a Picture'),
                      onTap: () async {
                        Navigator.pop(context,
                            await picker.getImage(source: ImageSource.camera));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('Choose from Gallery'),
                      onTap: () async {
                        Navigator.pop(context,
                            await picker.getImage(source: ImageSource.gallery));
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (pickedFile != null) {
            File imageFile = File(pickedFile.path);
            _uploadImage(imageFile);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text("${DateFormat('MMM dd, yyyy').format(DateTime.now())} - TODAY"),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_imageReferences.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  children: [
                    Duck(),
                    Text(
                      'No image added',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
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
                                return GestureDetector(
                                  onLongPress: () {
                                    _deleteImage(_imageReferences[index]);
                                  },
                                  child: Image.network(
                                    snapshot.data.toString(),
                                    width: 100,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
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
          _imageReferences.isEmpty
              ? SizedBox()
              : TextButton(
                  onPressed: () async {
                    await accomplishmentReport(context, widget.ids,
                        _commentController, _getTextReferences);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Attach Description"),
                      Icon(Icons.attach_file)
                    ],
                  ),
                ),
          _imageReferences.isEmpty
              ? SizedBox()
              : Flexible(
                  flex: 3,
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
                          return SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Expanded(
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
                                      color: Colors.green,
                                    ),
                                    endChild: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: GestureDetector(
                                        onLongPress: () =>
                                            // _showUpdateDeleteModal(record),
                                            deleteText(record),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                Text(record.comment
                                                    .replaceAll('<br />', '')),
                                                Positioned(
                                                  right: 0,
                                                  child: Text(DateFormat(
                                                          'hh:mm ')
                                                      .format(
                                                          DateFormat('HH:mm:ss')
                                                              .parse(time))),
                                                ),
                                              ],
                                            ),
                                          ),
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
                ),
        ],
      ),
    );
  }
}
