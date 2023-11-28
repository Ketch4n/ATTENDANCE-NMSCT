import 'package:attendance_nmsct/view/administrator/dashboard/admin/accomplishment/index.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/metadata/index.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/widgets/header.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admindtr extends StatefulWidget {
  const Admindtr({super.key, required this.name});
  final String name;
  @override
  State<Admindtr> createState() => _AdmindtrState();
}

class _AdmindtrState extends State<Admindtr> {
  List<Reference> _imageReferences = [];
  List _imageUrls = [];
  bool isLoading = true; // Track if data is loading
  int userId = 0;
  double screenHeight = 0;
  double screenWidth = 0;
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

  @override
  void initState() {
    super.initState();
    _getImageReferences();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            adminHeader(widget.name),
            Text(
                "${DateFormat('MMM dd, yyyy').format(DateTime.now())} - TODAY"),
            const SizedBox(
              height: 10,
            ),
            TabBar(
              tabs: [Tab(text: 'MetaData'), Tab(text: 'Accomplishment')],
            ),
            Expanded(
              child: TabBarView(
                children: [AdminMetaDataIndex(), AdminAccomplishmentIndex()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
