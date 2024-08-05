import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generatePdf() async {
  // CELL ALIGNMENT AND STYLE
  pw.Widget centeredCell(String text, {pw.TextStyle? style}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4), // Reduced padding
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: style ?? pw.TextStyle(fontSize: 8), // Reduced font size
      ),
    );
  }

  // INITIALIZE PDF
  final pdf = pw.Document();

  // TABLE PAGE
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(
              'Daily Time Record',
              style: const pw.TextStyle(fontSize: 16), // Reduced font size
            ),
            pw.SizedBox(height: 10), // Reduced space
            pw.Padding(
              padding: const pw.EdgeInsets.all(15), // Reduced padding
              child: pw.ListView(
                children: [
                  pw.Text(
                    "LASTNAME, FIRSTNAME",
                    style: const pw.TextStyle(
                      fontSize: 12, // Reduced font size
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text("(NAME)",
                      style: const pw.TextStyle(
                          fontSize: 10)), // Reduced font size
                ],
              ),
            ),
            pw.Expanded(
                child: pw.Container(
              child: pw.Column(
                children: [
                  // HEADER
                  pw.Table(
                    border: pw.TableBorder.all(
                        width: 1,
                        color: PdfColors.black), // Reduced border width
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Reduced column width
                      1: const pw.FlexColumnWidth(),
                      2: const pw.FlexColumnWidth(),
                      3: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          centeredCell('Day',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('AM',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('PM',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('UNDERTIME',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                        ],
                      ),
                    ],
                  ),
                  // SUB-HEADER

                  pw.Table(
                    border: pw.TableBorder.all(
                        width: 1,
                        color: PdfColors.black), // Reduced border width
                    columnWidths: {
                      0: pw.FixedColumnWidth(30), // Reduced column width
                      1: pw.FlexColumnWidth(),
                      2: pw.FlexColumnWidth(),
                      3: pw.FlexColumnWidth(),
                      4: pw.FlexColumnWidth(),
                      5: pw.FlexColumnWidth(),
                      6: pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          centeredCell('Date',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Arrival',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Departure',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Arrival',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Departure',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Hours',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                          centeredCell('Minutes',
                              style: const pw.TextStyle(
                                  fontSize: 10)), // Reduced font size
                        ],
                      ),
                      // BODY
                      for (var i = 0; i < 30; i++)
                        pw.TableRow(
                          children: [
                            centeredCell('${i + 1}',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('08:00 AM',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('12:00 PM',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('01:00 PM',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('05:00 PM',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('8 hrs',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                            centeredCell('0 min',
                                style: const pw.TextStyle(
                                    fontSize: 8)), // Reduced font size
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
