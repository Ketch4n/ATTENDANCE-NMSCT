import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Meta_Data extends StatefulWidget {
  const Meta_Data({super.key, required this.image});
  final Reference image;
  @override
  _Meta_DataState createState() => _Meta_DataState();
}

class _Meta_DataState extends State<Meta_Data> {
  String? _imageUrl; // Store the image URL
  FullMetadata? _imageMetadata; // Store the image metadata
  bool _loading = true; // Track whether the data is still loading

  @override
  void initState() {
    super.initState();
    _getImageUrlAndMetadata();
  }

  Future<void> _getImageUrlAndMetadata() async {
    try {
      // Fetch image URL
      final url = await widget.image.getDownloadURL();

      // Fetch image metadata
      final metadata = await widget.image.getMetadata();

      setState(() {
        _imageUrl = url;
        _imageMetadata = metadata;
        _loading = false; // Set loading to false when data is fetched
      });
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meta Data'),
        centerTitle: true,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator() // Show loading indicator while fetching data
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Image.network(
                      _imageUrl!,
                      height: 450,
                      width: 400,
                    ),
                    // SizedBox(height: 20),
                    ListTile(
                      title: Text(
                        'Description: ${_imageMetadata?.customMetadata?['description'] ?? 'No Description'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Date: ${_imageMetadata?.timeCreated}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    // ListTile(
                    //   title: Text(
                    //     'Date: ${_imageMetadata?.customMetadata?['Date taken'] ?? 'No Date'}',
                    //     style: TextStyle(fontSize: 18),
                    //   ),
                    // ),
                    // ListTile(
                    //   title: Text(
                    //     'Time: ${_imageMetadata?.customMetadata?['Time taken'] ?? 'No Time'}',
                    //     style: TextStyle(fontSize: 18),
                    //   ),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
