import 'package:attendance_nmsct/view/administrator/dashboard/admin/widgets/record.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/record.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSectionTab extends StatefulWidget {
  const AdminSectionTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AdminSectionTab> createState() => _AdminSectionTabState();
}

class _AdminSectionTabState extends State<AdminSectionTab> {
  List<Reference> _imageReferences = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true; // Track if data is loading
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  int userId = 0;
  // final TextEditingController _commentController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;

    final section = widget.name;
    final folderName = 'face_data/$section';

    try {
      final listResult = await storage.ref(folderName).listAll();
      final items = listResult.prefixes;

      List<Reference> allSubfolders = [];

      // Iterate through subdirectories
      for (Reference subdirectory in items) {
        final subfolderListResult = await subdirectory.listAll();
        final subfolderItems = subfolderListResult.prefixes;

        // Check if any subdirectory name contains _yearMonth
        if (subfolderItems
            .any((subfolder) => subfolder.name.contains(_yearMonth))) {
          // Add the main subdirectory to the list
          allSubfolders.add(subdirectory);
        }
      }

      setState(() {
        _imageReferences = allSubfolders.toList();
        isLoading = false;
      });

      print(_imageReferences);
    } catch (e) {
      print('Error listing files: $e');
      isLoading = false;
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
        appBar: AppBar(
          title: Text("Attendance"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final month = await showMonthYearPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2099),
                );

                if (month != null) {
                  setState(() {
                    _month = DateFormat('MMMM').format(month);
                    _yearMonth = DateFormat('yyyy-MM').format(month);
                  });
                }
                _getImageReferences();
              },
              child: Text(
                _month,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 15,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _imageReferences.isEmpty
                        ? ListView(
                            scrollDirection: Axis.vertical,
                            children: const [
                              Duck(),
                              Center(
                                child: Text(
                                  'No attendance this month !',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          )
                        : ListView(scrollDirection: Axis.vertical, children: [
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _imageReferences.map((imageRef) {
                                final imageName = imageRef.name;
                                return GestureDetector(
                                  onTap: () {
                                    String folder = imageRef.name;
                                    print("Clicked on file: $imageName");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminRecord(
                                          email: imageName,
                                          section_id: widget.ids,
                                          date: _yearMonth,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          // backgroundColor: Colors.blue,
                                          ),
                                      title: Text("Student"),
                                      subtitle: Text(imageName),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
