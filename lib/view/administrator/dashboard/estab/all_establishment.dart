import 'package:attendance_nmsct/view/administrator/dashboard/estab/add_location.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/model/EstabModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_room.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_sched.dart';

class AllEstablishment extends StatefulWidget {
  const AllEstablishment({super.key});

  @override
  State<AllEstablishment> createState() => _AllEstablishmentState();
}

class _AllEstablishmentState extends State<AllEstablishment> {
  List<EstabModel> interns = [];

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
        interns =
            data.map((estabData) => EstabModel.fromJson(estabData)).toList();
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
        // estabModel.creator_email,
        estabModel.location,
        estabModel.hours_required,
      ]);
    }

    // Save the Excel file
    var file = 'establishment_data_${DateTime.now().toIso8601String()}.xlsx';
    excel.save(fileName: file);
  }

  void _showAlertDialog(BuildContext context, String name, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              height: id != 0
                  ? MediaQuery.of(context).size.height / 2
                  : MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width / 3,
              child: id == 0
                  ? AddLocation(
                      title: name,
                      onDialogClose: () {
                        // Refresh the data when the dialog is closed
                        fetchInterns();
                      },
                    )
                  : ViewSched(
                      name: name,
                      id: id,
                      onDialogClose: () {
                        // Refresh the data when the dialog is closed
                        fetchInterns();
                      },
                    )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Establishment List'),
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
                      child: const Text(
                        'Export to Excel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        const title = "Register Establishment";

                        _showAlertDialog(context, title, 0);
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 200,
                            child: Text(
                              'Establishment Name',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 150,
                            child: Text(
                              'Coordinates',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Hours Required',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text(
                              'Arrival AM',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text(
                              'Departure AM',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text(
                              'Arrival PM',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text(
                              'Departure PM',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              'Schedule',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
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
                                          builder: (context) => EstabRoom(
                                            ids: parseID,
                                          ),
                                        ),
                                      );
                                      print("ID ${classmate.id}");
                                    },
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.asset(
                                            "assets/images/estab.png",
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            classmate.establishment_name,
                                            style:
                                                const TextStyle(fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      classmate.location,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.hours_required,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.in_am == null ||
                                            classmate.in_am!.isEmpty
                                        ? 'NOT SET'
                                        : classmate.in_am!,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.out_am == null ||
                                            classmate.out_am!.isEmpty
                                        ? 'NOT SET'
                                        : classmate.out_am!,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.in_pm == null ||
                                            classmate.in_pm!.isEmpty
                                        ? 'NOT SET'
                                        : classmate.in_pm!,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    classmate.out_pm == null ||
                                            classmate.out_pm!.isEmpty
                                        ? 'NOT SET'
                                        : classmate.out_pm!,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      _showAlertDialog(
                                          context,
                                          classmate.establishment_name,
                                          classmate.id);
                                    },
                                    child: const Icon(Icons.remove_red_eye),
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
              ? Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("NO ESTABLISHMENT REGISTERED"),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          const String name = "Register Establisment";
                          const int id = 0;
                          _showAlertDialog(context, name, id);
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text("Error fetching data")),
    );
  }
}
