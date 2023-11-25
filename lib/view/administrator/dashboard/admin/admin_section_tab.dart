import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/metadata/metadata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSectionTab extends StatefulWidget {
  const AdminSectionTab({super.key, required this.name});
  final String name;
  @override
  State<AdminSectionTab> createState() => _AdminSectionTabState();
}

class _AdminSectionTabState extends State<AdminSectionTab> {
  List<Reference> _imageReferences = [];
  bool isLoading = true; // Track if data is loading
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _getImageReferences();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final storedUserId = prefs.getString('userId');
    final folderName = 'face_data/$section/'; // Specify your folder name

    // List all files in the "face_data" folder
    try {
      // List all items in the root folder
      final rootFolderReference = storage.ref(folderName);
      final ListResult rootFolderResult = await rootFolderReference.listAll();

      List<Reference> allFiles = [];

      // Loop through subdirectories inside the root folder
      for (final prefix in rootFolderResult.prefixes) {
        final ListResult subFolderResult = await prefix.listAll();
        allFiles.addAll(subFolderResult.items);
      }

      setState(() {
        _imageReferences = allFiles;
        isLoading = false; // Data has loaded
      });
    } catch (e) {
      print('Error listing files: $e');
      isLoading = false; // Data has failed to load
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ElevatedButton(
        //   onPressed: () {},
        //   child: Text('Sort by ID'),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text("All MetaData - (unsorted)", style: Style.MontserratBold),
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
                                  metadata.customMetadata!['Location'] ?? 'N/A';
                              return Text('Location: $location');
                            }
                          }
                          return const Text('Fetching metadata...');
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
    );
  }
}
