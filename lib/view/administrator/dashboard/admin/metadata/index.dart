import 'package:attendance_nmsct/view/administrator/dashboard/admin/metadata/view.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminMetaDataIndex extends StatefulWidget {
  const AdminMetaDataIndex({super.key, required this.name});
  final String name;

  @override
  State<AdminMetaDataIndex> createState() => _AdminMetaDataIndexState();
}

class _AdminMetaDataIndexState extends State<AdminMetaDataIndex> {
  List<Reference> _imageReferences = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true; // Track if data is loading
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int userId = 0;
  // final TextEditingController _commentController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Future _getImageReferences() async {
    final storage = FirebaseStorage.instance;

    final section = widget.name;

    final folderName = 'face_data/$section'; // Specify your folder name

    try {
      final listResult = await storage.ref(folderName).listAll();
      final folders = listResult.prefixes;

      List<Reference> filteredFolders = [];

      for (var folder in folders) {
        // Get the list of subfolders in the current folder
        final subfoldersListResult = await folder.listAll();

        final subfolders = subfoldersListResult.prefixes;

        // Check if there is a subfolder with a name equal to _today
        if (subfolders.any((subfolder) => subfolder.name == _today)) {
          filteredFolders.add(
              subfolders.firstWhere((subfolder) => subfolder.name == _today));
        }
      }

      setState(() {
        _imageReferences = filteredFolders;
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
  void initState() {
    super.initState();
    _getImageReferences();
  }

  @override
  dispose() {
    super.dispose();
    _getImageReferences;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      key: _refreshIndicator,
      onRefresh: _getImageReferences,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: _imageReferences.length,
                    itemBuilder: (context, index) {
                      String parentFolderName =
                          _imageReferences[index].parent?.name ?? '';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminViewMetaData(
                                    email: parentFolderName,
                                    date: _imageReferences[index].name,
                                    section: widget.name)),
                          );
                          // Add your logic here for handling the tap event
                        },
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                            ),
                            subtitle: Text(parentFolderName),
                            title:
                                Text("Date: ${_imageReferences[index].name}"),
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
    );
  }
}
