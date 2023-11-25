import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/widgets/header.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Record extends StatefulWidget {
  const Record({super.key, required this.name, required this.date});
  final String name;
  final String date;
  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  List<Reference> _imageReferences = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getImageReferences();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final file = widget.date;
    final email = prefs.getString('userEmail');
    // final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final folderName =
        'face_data/$section/$email/$file'; // Specify your folder name

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
              child: ListView.builder(
                itemCount: _imageReferences.length,
                itemBuilder: (context, index) {
                  final imageRef = _imageReferences[index];
                  final imageName = imageRef.name; // Get the image name
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Container(
                      height: 70,
                      width: double.maxFinite,
                      decoration:
                          Style.boxdecor.copyWith(borderRadius: Style.radius12),
                      child: ListTile(
                        title: Text(imageName),
                        subtitle: FutureBuilder(
                          future: imageRef.getMetadata(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                final metadata = snapshot.data as FullMetadata;
                                final location =
                                    metadata.customMetadata!['Location'] ??
                                        'N/A';
                                return Text('Location: $location');
                              }
                            }
                            return const Text('Fetching metadata...');
                          },
                        ),
                        trailing: IconButton(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Meta_Data(image: imageRef),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
