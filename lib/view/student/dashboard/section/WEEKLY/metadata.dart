import 'dart:convert';
import 'dart:io';
import 'package:attendance_nmsct/data/server.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';

class Meta_Data extends StatefulWidget {
  const Meta_Data(
      {super.key,
      required this.week,
      required this.hte,
      required this.area,
      required this.sv,
      required this.comment});
  final String week;
  final String hte;
  final String area;
  final String sv;
  final String comment;
  @override
  _Meta_DataState createState() => _Meta_DataState();
}

class _Meta_DataState extends State<Meta_Data> {
  bool _loading = false; // Track whether the data is still loading

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Please Wait'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating PDF...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> documentero() async {
    setState(() {
      _loading = true; // Show loading screen
    });
    try {
      final response = await http.post(
        Uri.parse('https://app.documentero.com/api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "document": Server.id,
          "apiKey": Server.api,
          "format": "docx",
          "data": {
            "hte": widget.hte,
            "week": widget.week,
            "area": widget.area,
            "sv": widget.sv,
            "description": widget.comment
          }
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        final data2 = data['data'];
        if (data2 != null) {
          print('Download link: $data2');
          // Optionally, download the file using the link
          await downloadFile(data2);
        } else {
          print('No download link found in the response.');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Expired")));
        }
      } else {
        // Handle HTTP error
        print('Failed to load data. HTTP status code: ${response.statusCode}');
        // You might want to display an error message to the user
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // You might want to display an error message to the user
    }
  }

  Future<void> downloadFile(url) async {
    try {
      final response = await http.get(Uri.parse('$url'));

      if (response.statusCode == 200) {
        // Get the application's document directory
        // Get the Downloads directory
        final directory = Directory('/storage/emulated/0/Download');
        // Ensure the directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath = '${directory.path}/downloaded_file.docx';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('File downloaded successfully to: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Save Successfully in Downloads folder"),
          backgroundColor: Colors.green,
        ));
      } else {
        print(
            'Failed to download file. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    } finally {
      setState(() {
        _loading = false; // Hide loading screen
      });
      Navigator.of(context).pop();
    }
  }

// void _openDocument(String filePath) {
//   final result = OpenFile.open(filePath);
//   if (result.type != ResultType.done) {
//     print('Failed to open document: ${result.message}');
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.week),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        documentero();
                      },
                      child: const Text('Download to PDF'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
