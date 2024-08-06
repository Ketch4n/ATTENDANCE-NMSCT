import 'dart:convert';

import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AllStudentModel.dart';
import 'package:attendance_nmsct/model/EstabModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_room.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_sched.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/pdf.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/view_under_estab.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Signup(
                                  purpose: 'ESTAB',
                                )));
                      },
                      // style: ButtonStyle(
                      //   backgroundColor:
                      //       MaterialStateProperty.all<Color>(Colors.green),
                      // ),
                      child: Icon(Icons.add),
                    ),
                    // SizedBox(
                    //   width: 20,
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     generatePdf();
                    //   },
                    //   // style: ButtonStyle(
                    //   //   backgroundColor:
                    //   //       MaterialStateProperty.all<Color>(Colors.green),
                    //   // ),
                    //   child: Icon(Icons.remove_red_eye),
                    // ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    // controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Establishment Name')),
                        // DataColumn(label: Text('Creator Email')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Hours Required')),
                        DataColumn(label: Text('Schedule'))
                      ],
                      rows: interns
                          .map(
                            (classmate) => DataRow(
                              cells: [
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      String parseID = classmate.id.toString();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EstabRoom(ids: parseID
                                                      // name: Session.fname,
                                                      )));
                                      print("ID ${classmate.id}");
                                    },
                                    child: Row(
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
                                ),
                                // DataCell(
                                //   Text(
                                //     classmate.creator_email,
                                //     style: const TextStyle(fontSize: 12),
                                //   ),
                                // ),
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
                                DataCell(GestureDetector(
                                    onTap: () {
                                      _showAlertDialog(
                                          context,
                                          classmate.establishment_name,
                                          classmate.id);
                                      // Navigator.of(context)
                                      //     .push(MaterialPageRoute(
                                      //   builder: (context) => ViewSched(),
                                      // ));
                                    },
                                    child: Icon(Icons.remove_red_eye))),
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
              ? Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("NO ESTABLISHMENT REGISTERED"),
                      SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Signup(
                                      purpose: 'ESTAB',
                                    )));
                          },
                          child: Icon(Icons.add))
                    ],
                  ),
                )
              : Center(child: Text("Error fetching data")),
    );
  }
}

void _showAlertDialog(BuildContext context, name, id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width / 3,
          child: ViewSched(name: name, id: id),
        ),
      );
      //  AlertDialog(
      //   title: Text("Establishment Dialog"),
      //   content: Text('This is an AlertDialog'),
      //   actions: <Widget>[
      //     TextButton(
      //       child: Text('Cancel'),
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //     ),
      //     TextButton(
      //       child: Text('OK'),
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //     ),
      //   ],
      // );
    },
  );
}
