import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/record.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/widgets/header.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentSectionDTR extends StatefulWidget {
  const StudentSectionDTR({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<StudentSectionDTR> createState() => _StudentSectionDTRState();
}

class _StudentSectionDTRState extends State<StudentSectionDTR> {
  List<Reference> _imageReferences = [];

  bool isLoading = true; // Track if data is loading
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  int userId = 0;
  final TextEditingController _commentController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final email = prefs.getString('userEmail');
    // final date = DateFormat('MM-dd-yyyy').format(DateTime.now());
    final folderName = 'face_data/$section/$email'; // Specify your folder name

    try {
      final listResult = await storage.ref(folderName).listAll();
      final items = listResult.prefixes;
      final month = items.where((items) => items.name.contains(_yearMonth));
      // Filter items based on the name containing "datetoday"
      // final datetodayItems = items.where((item) => item.name.contains(
      //     date)); // You may need to adjust the condition based on your file naming convention
      setState(() {
        _imageReferences = month.toList();
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
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SectionHeader(name: widget.name),
        ListTile(
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: "NexaBold",
            fontSize: screenWidth / 15,
          ),
          title: Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(_month),

              TextButton(
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
                child: const FaIcon(
                  FontAwesomeIcons.refresh,
                  size: 18,
                  color: Colors.blue,
                ),
              ),
              // FaIcon(
              //   FontAwesomeIcons.refresh,
              //   size: 18,
              //   color: Colors.blue,
              // ),
            ],
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0, // Adjust the spacing between cards as needed
                  runSpacing: 8.0, // Adjust the run spacing as needed
                  children: _imageReferences.map((imageRef) {
                    final imageName = imageRef.name; // Get the image name
                    return GestureDetector(
                      onTap: () {
                        accomplishmentRecord(context);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                // child: const Text('AH'),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                imageName,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
