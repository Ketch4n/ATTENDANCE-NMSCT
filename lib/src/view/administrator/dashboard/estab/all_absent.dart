import 'dart:convert';

import 'package:attendance_nmsct/src/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/AbsentModel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAbsentStudent extends StatefulWidget {
  const AllAbsentStudent({super.key});
  // final String purpose;

  @override
  State<AllAbsentStudent> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllAbsentStudent> {
  List<AbsentModel> interns = [];
  List<AbsentModel> filteredInterns = [];
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
        await http.get(Uri.parse('${Server.host}users/student/all_absent.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      interns = data
          .map((classmateData) => AbsentModel.fromJson(classmateData))
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
            headers: ['Student Name', 'Email', 'Reason', 'Status', 'Date'],
            data: interns.map((intern) {
              return [
                intern.lname,
                intern.email,
                intern.reason,
                intern.status,
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

  void action(String absent, String email) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Select Option'),
          content: const Text('Approved or Declined'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                const String stats = "Declined";

                Navigator.of(context).pop();
                _actionDone(absent, stats, email);
              },
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                const String stats = "Approved";

                _actionDone(absent, stats, email);

                Navigator.of(context).pop();
              },
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _actionDone(String absent, String stats, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/update_absent.php'),
        body: {'absent_id': absent, 'status': stats},
      );
      if (response.statusCode == 200) {
        print("NOW OR NEVER :$absent");
        final announce = "Your absent request is $stats";

        // If deletion is successful, refresh the list
        fetchInterns();
        sendToAll(context, email, announce, stats);
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
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
                          DataColumn(label: Text('Reason')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Option')),
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
                                      classmate.reason,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.status,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      classmate.date,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(ElevatedButton(
                                      onPressed: () {
                                        action(classmate.id, classmate.email!);
                                      },
                                      child: const Icon(Icons.edit))),
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
