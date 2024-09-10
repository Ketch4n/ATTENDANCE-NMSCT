// import 'dart:io';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/services.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// class Meta_Data extends StatefulWidget {
//   const Meta_Data({super.key, required this.image});
//   final Reference image;
//   @override
//   _Meta_DataState createState() => _Meta_DataState();
// }

// class _Meta_DataState extends State<Meta_Data> {
//   String? _imageUrl; // Store the image URL
//   FullMetadata? _imageMetadata; // Store the image metadata
//   bool _loading = true; // Track whether the data is still loading

//   @override
//   void initState() {
//     super.initState();
//     _getImageUrlAndMetadata();
//   }

//   Future<void> _getImageUrlAndMetadata() async {
//     try {
//       // Fetch image URL
//       final url = await widget.image.getDownloadURL();

//       // Fetch image metadata
//       final metadata = await widget.image.getMetadata();

//       setState(() {
//         _imageUrl = url;
//         _imageMetadata = metadata;
//         _loading = false; // Set loading to false when data is fetched
//       });
//     } catch (e) {
//       print('Error fetching image data: $e');
//     }
//   }

//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Please Wait'),
//           content: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 20),
//               Text('Generating PDF...'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> exportToPDF() async {
//     _showLoadingDialog(); // Show loading dialog

//     final pdf = pw.Document();
//     final netImage = _imageUrl!;
//     final response = await http.get(Uri.parse(netImage));
//     final Uint8List imageData = response.bodyBytes;

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Date: ${_imageMetadata?.timeCreated}',
//                 style: pw.TextStyle(fontSize: 18),
//               ),
//               pw.Text(
//                 'Location: ${_imageMetadata?.customMetadata?['Location'] ?? 'No Location'}',
//                 style: pw.TextStyle(fontSize: 18),
//               ),
//               pw.SizedBox(height: 40),
//               pw.Align(
//                   child: pw.Text("DAILY REPORT",
//                       style: pw.TextStyle(fontSize: 20))),
//               pw.SizedBox(height: 20),
//               pw.Align(
//                 alignment: pw.Alignment.topCenter,
//                 child: pw.Text(
//                   _imageMetadata?.customMetadata?['description'] ??
//                       'No Description',
//                   style: pw.TextStyle(fontSize: 18),
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Center(
//                 child: pw.Image(
//                   pw.MemoryImage(imageData),
//                   height: 450,
//                   width: 400,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     final String pdfPath = (await getTemporaryDirectory()).path;
//     final String pdfFilePath = '$pdfPath/report.pdf';
//     final File pdfFile = File(pdfFilePath);
//     await pdfFile.writeAsBytes(await pdf.save());

//     Navigator.of(context).pop(); // Dismiss the loading dialog

//     // Open or share PDF file
//     _openPDF(pdfFilePath);
//   }

//   void _openPDF(String filePath) async {
//     try {
//       final file = File(filePath);
//       if (Platform.isIOS || Platform.isAndroid) {
//         await OpenFile.open(file.path);
//       }
//     } on PlatformException catch (e) {
//       print("Error opening PDF: ${e.toString()}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meta Data'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: _loading
//             ? CircularProgressIndicator() // Show loading indicator while fetching data
//             : SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     ElevatedButton(
//                       onPressed: exportToPDF,
//                       child: Text('Download to PDF'),
//                     ),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     Image.network(
//                       _imageUrl!,
//                       height: 250,
//                       width: 200,
//                     ),
//                     ListTile(
//                       title: Text(
//                         'Date: ${_imageMetadata?.timeCreated}',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                     ListTile(
//                       title: Text(
//                         'Location: ${_imageMetadata?.customMetadata?['Location'] ?? 'No Location'}',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                     ListTile(
//                       title: Text(
//                         'Description: ${_imageMetadata?.customMetadata?['description'] ?? 'No Description'}',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
