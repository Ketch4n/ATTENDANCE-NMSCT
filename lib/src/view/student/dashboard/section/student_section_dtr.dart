import 'dart:convert';

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/view/student/dashboard/establishment/widgets/record.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentSectionDTR extends StatefulWidget {
  const StudentSectionDTR(
      {super.key,
      required this.name,
      required this.ids,
      required this.section});
  final String name;
  final String ids;
  final String section;
  @override
  State<StudentSectionDTR> createState() => _StudentSectionDTRState();
}

class _StudentSectionDTRState extends State<StudentSectionDTR> {
  List<Reference> _imageReferences = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true; // Track if data is loading
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  int userId = 0;
  late String estabname = "";
  // final TextEditingController _commentController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Future _getImageReferences() async {
    print("IDS${widget.ids}");
    print("name${widget.name}");
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = kIsWeb ? estabname : widget.name;
    final email = kIsWeb ? widget.ids : prefs.getString('userEmail');
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

  Future<void> getEstab() async {
    try {
      print("IDS${widget.ids}");
      print("name${widget.name}");
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/all_establishment.php'),
        body: {
          'estab_id': widget.name,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final Map<String, dynamic> firstItem = data[0];
          final String establishmentName = firstItem['establishment_name'];
          setState(() {
            estabname = establishmentName;
          });
          _getImageReferences();
        } else {
          print('No establishment data found');
        }
      } else {
        print('Server returned an error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      getEstab();
    } else {
      _getImageReferences();
    }
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
            const SizedBox(height: kIsWeb ? 10 : 10),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "NexaBold",
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _imageReferences.isEmpty
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
                    : isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
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
                                    print(widget.ids);

                                    print(widget.section);
                                    print(estabname);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Record(
                                          ids: widget.ids,
                                          name:
                                              kIsWeb ? estabname : widget.name,
                                          date: folder,
                                          section: widget.section,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const CircleAvatar(
                                              // backgroundColor: Colors.blue,
                                              ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            imageName,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
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
