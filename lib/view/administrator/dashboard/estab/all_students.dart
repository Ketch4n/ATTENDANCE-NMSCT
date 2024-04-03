import 'dart:convert';

import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_dtr.dart';
import 'package:attendance_nmsct/view/student/dtr_details.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({Key? key}) : super(key: key);

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  List<AllStudentModel> interns = [];
  List<AllStudentModel> filteredInterns = [];
  final horizontalController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  void fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/establishment/all_students.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        interns = data
            .map((classmateData) => AllStudentModel.fromJson(classmateData))
            .toList();
        filteredInterns = interns; // Initialize filtered list
        setState(() {});
      } else {
        print('Server returned an error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error accordingly
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

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow([
      'Student Name',
      'Email',
      'Section',
      'Birth Date',
      'Address',
    ]);

    // Add data rows
    for (var estabModel in interns) {
      sheet.appendRow([
        estabModel.lname,
        estabModel.fname,
        estabModel.email,
        estabModel.section,
        estabModel.bday,
        estabModel.address,
      ]);
    }

    // Save the Excel file
    var file = 'establishment_data_${DateTime.now().toIso8601String()}.xlsx';
    excel.save(fileName: file);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('All Students List'),
        centerTitle: true,
      ),
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
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                exportToExcel();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: Text(
                'Export to Excel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: filteredInterns.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Section')),
                          DataColumn(label: Text('Birth Date')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('View DTR'))
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
                                                '${classmate.lname}, ${classmate.fname}',
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
                                  DataCell(ElevatedButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StudentDTRDetails(
                                                  id: classmate.id,
                                                ))),
                                    child: Icon(Icons.remove_red_eye),
                                  )),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : filteredInterns.isEmpty
                      ? Center(child: Text("No matching interns found"))
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
