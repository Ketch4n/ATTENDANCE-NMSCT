import 'dart:convert';
import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_dtr.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/student_section_dtr.dart';
import 'package:attendance_nmsct/view/student/dtr_details.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({Key? key}) : super(key: key);

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  List<AllStudentModel> interns = [];
  List<AllStudentModel> filteredInterns = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  void fetchInterns() async {
    final prefs = await SharedPreferences.getInstance();
    final estab_id = prefs.getString('adminEstab');
    print("estab : $estab_id");
    print("role : ${Session.role}");

    final response = await http.post(
      Uri.parse('${Server.host}users/establishment/all_students.php'),
      body: {
        'estab_id': estab_id,
        'role': Session.role,
      },
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

  static const List<String> list = <String>[
    '',
    'Active',
    'Inactive',
    'Archived'
  ];

  String dropdownValue = '';

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
              constraints: Session.role == "SUPER ADMIN"
                  ? BoxConstraints(maxWidth: screenwidth / 3)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterInterns,
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
                          filterByStatus(
                              dropdownValue); // Filter the list based on status
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
                  onPressed: () {
                    exportToExcel();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text(
                    'Export to Excel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white, // Icon color of the button
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Signup(
                              purpose: 'INTERN',
                            )));
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: filteredInterns.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Name')),
                              const DataColumn(label: Text('Email')),
                              const DataColumn(label: Text('Section')),
                              const DataColumn(label: Text('Birth Date')),
                              const DataColumn(label: Text('Address')),
                              const DataColumn(label: Text('View Records')),
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
                                                // Profile Image with a scalable size
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50), // Use BorderRadius.circular for radius
                                                  child: Image.asset(
                                                    "assets/images/admin.png",
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                        10), // Space between image and text
                                                Expanded(
                                                  child: Wrap(
                                                    children: [
                                                      Text(
                                                        '${classmate.lname}, ${classmate.fname}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis, // Handle overflow gracefully
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                if (classmate
                                                        .establishment_id ==
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
                                                            .establishment_id,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text("DTR"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                print(
                                                    "Name ${classmate.establishment_id}");
                                                print("Ids ${classmate.email}");
                                                print(
                                                    "section ${classmate.section}");

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentSectionDTR(
                                                            name: classmate
                                                                .establishment_id,
                                                            ids:
                                                                classmate.email,
                                                            section: classmate
                                                                .section),
                                                  ),
                                                );
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
