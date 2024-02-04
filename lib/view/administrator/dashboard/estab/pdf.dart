// import 'dart:io';
// import 'package:attendance_nmsct/model/EstabTodayModel.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// Future<void> generateEstabDTRPDF(List<EstabTodayModel> dtrData) async {
//   final pdf = pw.Document();

//   pdf.addPage(
//     pw.Page(
//       build: (pw.Context context) => pw.Center(
//         child: pw.Table.fromTextArray(
//           border: pw.TableBorder.all(),
//           headerStyle: pw.TextStyle(
//             color: PdfColors.white,
//           ),
//           headerDecoration: pw.BoxDecoration(),
//           cellAlignment: pw.Alignment.centerLeft,
//           data: <List<String>>[
//             // Header row
//             <String>[
//               'Name',
//               'Date',
//               'Time-In AM',
//               'Time-Out AM',
//               'Time-In PM',
//               'Time-Out PM',
//             ],
//             // Data rows
//             ...dtrData.map(
//               (dtr) => <String>[
//                 dtr.lname,
//                 dtr.date,
//                 dtr.time_in_am,
//                 dtr.in_am,
//                 dtr.time_out_am,
//                 dtr.out_am,
//                 dtr.time_in_pm,
//                 dtr.in_pm,
//                 dtr.time_out_pm,
//                 dtr.out_pm,
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//   final file = File('estab_dtr_report.pdf');
//   await file.writeAsBytes(await pdf.save());

//   OpenFile.open(file.path);
// }
