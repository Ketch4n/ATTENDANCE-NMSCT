import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:docx_template/docx_template.dart';

class Meta_Data extends StatefulWidget {
  const Meta_Data({super.key, required this.week, required this.comment});
  final String week;
  final String comment;
  @override
  _Meta_DataState createState() => _Meta_DataState();
}

class _Meta_DataState extends State<Meta_Data> {
  bool _loading = true; // Track whether the data is still loading
  final TextEditingController hte = TextEditingController();

  final TextEditingController area = TextEditingController();
  final TextEditingController sv = TextEditingController();

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

  Future<void> exportToPDF() async {
    _showLoadingDialog();

    final pdf = pw.Document();
    final ByteData bytes = await rootBundle.load('assets/border.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final pw.ImageProvider imageProvider = pw.MemoryImage(imageData);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(children: [
            pw.Positioned.fill(
              child: pw.Image(imageProvider, fit: pw.BoxFit.fill),
            ),
            pw.Padding(
              padding:
                  const pw.EdgeInsets.only(top: 130.0, left: 50, right: 50),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HTE Name: ${hte.text}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Assigned Area: ${area.text}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Supervisor Name: ${sv.text}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Align(
                      child: pw.Text("Weekly Report",
                          style: pw.TextStyle(
                              fontSize: 12,
                              fontStyle: pw.FontStyle.italic,
                              fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      // widget.comment.replaceAll('<br />', ''),
                      widget.comment.replaceAll('<br />', ''),

                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );

    final String pdfPath = (await getTemporaryDirectory()).path;
    final String pdfFilePath = '$pdfPath/report.pdf';
    final File pdfFile = File(pdfFilePath);
    await pdfFile.writeAsBytes(await pdf.save());

    Navigator.of(context).pop(); // Dismiss the loading dialog

    // Open or share PDF file
    _openPDF(pdfFilePath);
  }

  void _openPDF(String filePath) async {
    try {
      final file = File(filePath);
      if (Platform.isIOS || Platform.isAndroid) {
        await OpenFile.open(file.path);
      }
    } on PlatformException catch (e) {
      print("Error opening PDF: ${e.toString()}");
    }
  }

  void generateWord() async {
    try {
      // Load the template file from assets
      final data = await rootBundle.load('assets/week.docx');
      final bytes = data.buffer.asUint8List();

      // Create a DocxTemplate instance from the bytes
      final docx = await DocxTemplate.fromBytes(bytes);

      // Create content to be added to the document
      final content = Content()
        ..add(TextContent("hte", "Quack"))
        ..add(TextContent("week", "Quack"))
        ..add(TextContent("area", "Quack"))
        ..add(TextContent("sv", "Quack"))
        ..add(TextContent("description", "Quack"));

      // Generate the document
      final docBytes = await docx.generate(content);

      // Get the application's document directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/generated.docx');

      // Write the generated document to the file
      if (docBytes != null) {
        await file.writeAsBytes(docBytes);
        print('Document generated at ${file.path}');
        // _openDocument should handle the correct type
        // _openDocument(docBytes);
      } else {
        print('No document generated');
      }
    } catch (e) {
      print('Error generating document: $e');
    }
  }

  Future<void> documentero() async {
    try {
      final response = await http.post(
        Uri.parse('https://app.documentero.com/api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "document": "dPBHyEOmLlNoT2MRlXEZ",
          "apiKey": "BDIOF2Y-MT6EBSY-XVHVUBA-KGGNNTA",
          "format": "docx",
          "data": {
            "hte": "hte",
            "week": "week",
            "area": "area",
            "sv": "sv",
            "description": "description"
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
      } else {
        print(
            'Failed to download file. HTTP status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: hte,
                decoration: Style.textdesign.copyWith(hintText: 'HTE Name'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: area,
                  decoration:
                      Style.textdesign.copyWith(hintText: 'Assigned Area'),
                ),
              ),
              TextField(
                controller: sv,
                decoration:
                    Style.textdesign.copyWith(hintText: 'Supervisor Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final String nhte = hte.text;
                  final String nweek = widget.week;
                  final String narea = area.text;
                  final String nsv = sv.text;

                  // if (nhte.isEmpty ||
                  //     nweek.isEmpty ||
                  //     narea.isEmpty ||
                  //     nsv.isEmpty) {
                  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  //     content: Text("Fill up all the fields"),
                  //     backgroundColor: Colors.blue,
                  //   ));
                  // } else {
                  // exportToPDF();
                  documentero();
                  // }
                },
                child: const Text('Download to PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
