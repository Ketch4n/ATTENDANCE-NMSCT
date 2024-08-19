import 'dart:convert';

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllLateStudent extends StatefulWidget {
  const AllLateStudent({super.key});
  // final String purpose;

  @override
  State<AllLateStudent> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllLateStudent> {
  List<EstabTodayModel> interns = [];
  List<EstabTodayModel> filteredInterns = [];
  final horizontalController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  void fetchInterns() async {
    final prefs = await SharedPreferences.getInstance();

    final estabId = prefs.getString('adminEstab');
    print("estab : $estabId");
    print("role : ${Session.role}");

    final response =
        await http.get(Uri.parse('${Server.host}users/student/all_late.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      interns = data
          .map((classmateData) => EstabTodayModel.fromJson(classmateData))
          .toList();
      filteredInterns = interns; // Initialize filtered list
      setState(() {});
    } else {
      print('Server returned an error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void filterInterns(String query) {
    setState(() {
      filteredInterns = interns
          .where((intern) =>
              intern.email!.toLowerCase().contains(query.toLowerCase()) ||
              intern.lname!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> exportToPDF() async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Student Name',
              'Email',
              'Time-in AM',
              'Time-out AM',
              'Time-in PM',
              'Time-out PM',
              'Date'
            ],
            data: interns.map((intern) {
              return [
                intern.lname,
                intern.email,
                intern.time_in_am,
                intern.time_out_am,
                intern.time_in_pm,
                intern.time_out_pm,
                intern.date,
              ];
            }).toList(),
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Session.role == "SUPER ADMIN"
          ? AppBar(
              title: const Text('All Students List'),
              centerTitle: true,
            )
          : null,
      body: Center(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: screenwidth / 3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterInterns,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                exportToPDF();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              child: const Text(
                'Export to PDF',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: filteredInterns.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Time-in AM')),
                          DataColumn(label: Text('Time-out AM')),
                          DataColumn(label: Text('Time-in PM')),
                          DataColumn(label: Text('Time-out PM')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: filteredInterns
                            .map(
                              (classmate) => DataRow(
                                cells: [
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        // Navigator.of(context)
                                        //     .push(MaterialPageRoute(
                                        //         builder: (context) => EstabDTR(
                                        //               id: classmate.id,
                                        //               name: classmate.lname,
                                        //             )));
                                      },
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: Style.radius50,
                                            child: Image.asset(
                                              "assets/images/admin.png",
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Wrap(
                                            children: [
                                              Text(
                                                '${classmate.lname}',
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.email!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.time_in_am,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.time_out_am,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.time_in_pm,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.time_out_pm,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.date,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : filteredInterns.isEmpty
                      ? const Center(child: Text("No matching interns found"))
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
