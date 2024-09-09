import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/model/AllStudentModel.dart';
import 'package:attendance_nmsct/src/view/student/dashboard/section/student_section_dtr.dart';
import 'package:attendance_nmsct/src/view/student/dtr_details.dart';
import 'package:attendance_nmsct/src/widgets/confirmation.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:attendance_nmsct/src/auth/signup.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({super.key, required this.course, required this.sy});
  final String course;
  final String sy;

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  List<AllStudentModel> interns = [];
  List<AllStudentModel> filteredInterns = [];
  TextEditingController searchController = TextEditingController();
  String error = '';
  String dropdownValue = '';
  static const List<String> statusList = <String>[
    '',
    'Active',
    'Inactive',
    'Archived'
  ];

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
      final course = widget.course;
      final sy = widget.sy;
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/all_students.php'),
        body: {'role': Session.role, 'course': course, 'school_year': sy},
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
      filteredInterns = status.isEmpty
          ? interns
          : interns.where((intern) => intern.status == status).toList();
    });
  }

  Future<void> exportToPDF() async {
    final pdf = pw.Document();
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
            data: interns.map((student) {
              return [
                student.lname,
                student.fname,
                student.email,
                student.section,
                student.bday,
                student.address,
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
                const SizedBox(width: 20),
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
            const SizedBox(height: 20),
            if (filteredInterns.isNotEmpty)
              Expanded(
                  child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Name')),
                      const DataColumn(label: Text('Email')),
                      const DataColumn(label: Text('Birth Date')),
                      const DataColumn(label: Text('Address')),
                      const DataColumn(label: Text('Course')),
                      const DataColumn(label: Text('Section')),
                      const DataColumn(label: Text('Semester')),
                      const DataColumn(label: Text('School Year')),
                      DataColumn(
                        label: Row(
                          children: [
                            const Text('Status'),
                            PopupMenuButton<String>(
                              onSelected: (String value) {
                                setState(() {
                                  dropdownValue = value;
                                  filterByStatus(value);
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return statusList.map<PopupMenuEntry<String>>(
                                    (String value) {
                                  return PopupMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList();
                              },
                              icon: const Icon(Icons.arrow_drop_down, size: 40),
                            ),
                          ],
                        ),
                      ),
                      const DataColumn(label: Text('View Records')),
                      const DataColumn(label: Text('Option')),
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
                                        borderRadius: BorderRadius.circular(50),
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
                                              overflow: TextOverflow.ellipsis,
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
                                  classmate.course,
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
                                  classmate.semester,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                Text(
                                  classmate.school_year,
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
                                              content:
                                                  Text("No Establishment yet"),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentDTRDetails(
                                                id: classmate.id,
                                                estab_id:
                                                    classmate.establishment_id!,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("DTR"),
                                    ),
                                    const SizedBox(width: 5),
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
                                                name:
                                                    classmate.establishment_id!,
                                                ids: classmate.email,
                                                section: classmate.section,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("Report"),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () async {
                                    const status = "Archived";
                                    await confirm(
                                        context, classmate.id, status);
                                    setState(() {});
                                  },
                                  child: const Icon(Icons.edit),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ))
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        DataTable(
                          columns: [
                            const DataColumn(label: Text('Name')),
                            const DataColumn(label: Text('Email')),
                            const DataColumn(label: Text('Birth Date')),
                            const DataColumn(label: Text('Address')),
                            const DataColumn(label: Text('Course')),
                            const DataColumn(label: Text('Section')),
                            const DataColumn(label: Text('Semester')),
                            const DataColumn(label: Text('School Year')),
                            DataColumn(
                              label: Row(
                                children: [
                                  const Text('Status'),
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      setState(() {
                                        dropdownValue = value;
                                        filterByStatus(value);
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return statusList
                                          .map<PopupMenuEntry<String>>(
                                              (String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList();
                                    },
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 40),
                                  ),
                                ],
                              ),
                            ),
                            const DataColumn(label: Text('View Records')),
                            const DataColumn(label: Text('Option')),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                            ])
                          ],
                        ),
                        Duck(),
                        Text("No Students Found")
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
