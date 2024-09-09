import 'package:attendance_nmsct/src/model/EstabTodayModel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

// CELL ALIGNMENT AND STYLE
pw.Widget centeredCell(String text, {pw.TextStyle? style}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: style ?? const pw.TextStyle(fontSize: 8),
    ),
  );
}

Future<void> generatePdf(
    List<EstabTodayModel> dtrData, String latestGrandTotalHours) async {
  if (dtrData.isEmpty) return;
  // INITIALIZE PDF
  final pdf = pw.Document();

  DateTime firstDate = DateFormat('yyyy-MM-dd').parse(dtrData[0].date ?? '');
  String monthFormatted = DateFormat('MMM yyyy').format(firstDate);

  // TABLE PAGE
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(
              'Daily Time Record',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.all(15),
              child: pw.ListView(
                children: [
                  pw.Text(
                    dtrData[0].lname!,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text("(NAME)", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.ListView(
              children: [
                pw.Text(
                  monthFormatted,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 20)
              ],
            ),
            pw.Expanded(
              child: pw.Container(
                child: pw.Column(
                  children: [
                    // HEADER
                    pw.Table(
                      border:
                          pw.TableBorder.all(width: 1, color: PdfColors.black),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(30),
                        1: const pw.FlexColumnWidth(),
                        2: const pw.FlexColumnWidth(),
                        3: const pw.FlexColumnWidth(),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            centeredCell('Day',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('AM',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('PM',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('UNDERTIME',
                                style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    // SUB-HEADER
                    pw.Table(
                      border:
                          pw.TableBorder.all(width: 1, color: PdfColors.black),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(30),
                        1: const pw.FlexColumnWidth(),
                        2: const pw.FlexColumnWidth(),
                        3: const pw.FlexColumnWidth(),
                        4: const pw.FlexColumnWidth(),
                        5: const pw.FlexColumnWidth(),
                        6: const pw.FlexColumnWidth(),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            centeredCell('Date',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Arrival',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Departure',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Arrival',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Departure',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Hours',
                                style: const pw.TextStyle(fontSize: 10)),
                            centeredCell('Minutes',
                                style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                        // BODY
                        for (var i = 0; i < dtrData.length; i++)
                          pw.TableRow(
                            children: [
                              centeredCell(
                                  DateFormat('d').format(
                                    DateFormat('yyyy-MM-dd')
                                        .parse(dtrData[i].date ?? ''),
                                  ),
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell(dtrData[i].time_in_am ?? '',
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell(dtrData[i].time_out_am ?? '',
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell(dtrData[i].time_in_pm ?? '',
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell(dtrData[i].time_out_pm ?? '',
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell('Calculated Hours', // Placeholder
                                  style: const pw.TextStyle(fontSize: 8)),
                              centeredCell('Calculated Minutes', // Placeholder
                                  style: const pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 20),

                    pw.Row(children: [
                      pw.Text("Total Hours rendered:"),
                      pw.Text(latestGrandTotalHours)
                    ])
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
