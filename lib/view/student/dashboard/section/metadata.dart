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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            if (_loading)
              const CircularProgressIndicator(), // Show loading indicator while fetching data

            if (!_loading)
              Image.network(
                _imageUrl!,
                height: 400,
                width: 300,
              ),

            if (!_loading)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Date and Time : ${_imageMetadata?.customMetadata?['Date taken']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Location : ${_imageMetadata?.customMetadata?['Location']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
