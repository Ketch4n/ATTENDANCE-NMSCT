// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_section_dtr.dart';
import 'package:attendance_nmsct/view/student/dtr_details.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({super.key});

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  List<AllStudentModel> interns = [];
  List<AllStudentModel> filteredInterns = [];
  TextEditingController searchController = TextEditingController();
  String error = '';
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    fetchInterns();
    searchController.addListener(() {
      filterInterns(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchInterns() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/all_students.php'),
        body: {
          'role': Session.role,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<AllStudentModel> dtr =
            data.map((dtrData) => AllStudentModel.fromJson(dtrData)).toList();
        setState(() {
          interns = dtr;
          filteredInterns = dtr;
        });
      } else {
        setState(() {
          error = 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
      });
    }
  }

  void filterInterns(String query) {
    setState(() {
      filteredInterns = interns
          .where((intern) =>
              intern.fname.toLowerCase().contains(query.toLowerCase()) ||
              intern.lname.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void filterByStatus(String status) {
    setState(() {
      if (status.isEmpty) {
        filteredInterns = interns; // Show all if no status is selected
      } else {
        filteredInterns =
            interns.where((intern) => intern.status == status).toList();
      }
    });
  }

  Future<void> exportToPDF() async {
    final pdf = pw.Document();

    // Add headers
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Student Name',
              'First Name',
              'Email',
              'Section',
              'Birth Date',
              'Address',
            ],
            data: interns.map((estabModel) {
              return [
                estabModel.lname,
                estabModel.fname,
                estabModel.email,
                estabModel.section,
                estabModel.bday,
                estabModel.address,
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

  static const List<String> list = <String>[
    '',
    'Active',
    'Inactive',
    'Archived'
  ];

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
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: const OutlineInputBorder(),
                    suffixIcon: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      iconSize: 40,
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValue = value!;
                          filterByStatus(dropdownValue);
                        });
                      },
                      underline: const SizedBox.shrink(),
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: exportToPDF,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                  ),
                  child: const Text(
                    'Export to PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Signup(
                              purpose: 'INTERN',
                              reload: fetchInterns,
                            )));
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            filteredInterns.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Birth Date')),
                            DataColumn(label: Text('Address')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('View Records')),
                          ],
                          rows: filteredInterns
                              .map(
                                (classmate) => DataRow(
                                  cells: [
                                    DataCell(
                                      GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.asset(
                                                "assets/images/admin.png",
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${classmate.lname}, ${classmate.fname}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        classmate.email,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        classmate.section,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        classmate.bday,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        classmate.address,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        classmate.status.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: classmate.status == "Active"
                                                ? Colors.green
                                                : classmate.status == "Inactive"
                                                    ? Colors.orange
                                                    : Colors.grey),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (classmate.establishment_id ==
                                                      null ||
                                                  classmate.establishment_id ==
                                                      "none") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "No Establishment yet"),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentDTRDetails(
                                                      id: classmate.id,
                                                      estab_id: classmate
                                                          .establishment_id!,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text("DTR"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (classmate.establishment_id ==
                                                      null ||
                                                  classmate.establishment_id ==
                                                      "none") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "No Establishment for Report"),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentSectionDTR(
                                                            name: classmate
                                                                .establishment_id!,
                                                            ids:
                                                                classmate.email,
                                                            section: classmate
                                                                .section),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text("Report"),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Duck(), Text("No Students Found")],
                  )
          ],
        ),
      ),
    );
  }
}
