import 'dart:convert';

import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
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
  final horizontalController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Students List'),
        centerTitle: true,
      ),
      body: interns.isNotEmpty
          ? Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                // controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Section')),
                    DataColumn(label: Text('Birth Date')),
                    DataColumn(label: Text('Address')),
                  ],
                  rows: interns
                      .map(
                        (classmate) => DataRow(
                          cells: [
                            DataCell(
                              Row(
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
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
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
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          : interns.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Center(child: Text("Error fetching data")),
    );
  }
}
