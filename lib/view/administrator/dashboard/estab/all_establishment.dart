import 'dart:convert';

import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
import 'package:attendance_nmsct/model/EstabModel.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';

class AllEstablishment extends StatefulWidget {
  const AllEstablishment({Key? key}) : super(key: key);

  @override
  State<AllEstablishment> createState() => _AllEstablishmentState();
}

class _AllEstablishmentState extends State<AllEstablishment> {
  List<EstabModel> interns = [];
  final horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  void fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/establishment/all_establishment.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        interns = data
            .map((classmateData) => EstabModel.fromJson(classmateData))
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

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow([
      'Establishment Name',
      'Creator Email',
      'Location',
      'Hours Required',
    ]);

    // Add data rows
    for (var estabModel in interns) {
      sheet.appendRow([
        estabModel.establishment_name,
        estabModel.creator_email,
        estabModel.location,
        estabModel.hours_required,
      ]);
    }

    // Save the Excel file
    var file = 'establishment_data_${DateTime.now().toIso8601String()}.xlsx';
    excel.save(fileName: file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Establishment List'),
        centerTitle: true,
      ),
      body: interns.isNotEmpty
          ? Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    exportToExcel();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: Text(
                    'Export to Excel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    // controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Establishment Name')),
                        DataColumn(label: Text('Creator Email')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Hours Required')),
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
                                          "assets/images/estab.png",
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Wrap(
                                        children: [
                                          Text(
                                            classmate.establishment_name,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.creator_email,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.location,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.hours_required,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            )
          : interns.isEmpty
              ? Center(child: Text("NO ESTABLISHMENT REGISTERED"))
              : Center(child: Text("Error fetching data")),
    );
  }
}
