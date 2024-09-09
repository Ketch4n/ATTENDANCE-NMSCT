import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

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

  Future<void> exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Date: ${_imageMetadata?.timeCreated}',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.topCenter,
                child: pw.Text(
                  'Description: ${_imageMetadata?.customMetadata?['description'] ?? 'No Description'}',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
    final String pdfPath = (await getTemporaryDirectory()).path;
    final String pdfFilePath = '$pdfPath/report.pdf';
    final File pdfFile = File(pdfFilePath);
    await pdfFile.writeAsBytes(await pdf.save());

    // Open or share PDF file
    _openPDF(pdfFilePath);
  }

  void _openPDF(String filePath) {
    Future<void> _loadPdf() async {
      try {
        final file = File(filePath);
        if (Platform.isIOS) {
          await OpenFile.open(file.path);
        } else {
          await OpenFile.open(file.path);
        }
      } on PlatformException catch (e) {
        print("Error opening PDF: ${e.toString()}");
      }
    }

    _loadPdf();
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
            ? CircularProgressIndicator() // Show loading indicator while fetching data
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
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
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Date: ${_imageMetadata?.timeCreated}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: exportToPDF,
                      child: Text('Download to PDF'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
