// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/model/TodayModel.dart';
import 'package:attendance_nmsct/view/student/calculate_distance.dart';
import 'package:excel/excel.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class StudentDTRDetails extends StatefulWidget {
  const StudentDTRDetails(
      {super.key, required this.id, required this.estab_id});

  final String id;
  final String estab_id;

  @override
  State<StudentDTRDetails> createState() => _StudentDTRDetailsState();
}

class _StudentDTRDetailsState extends State<StudentDTRDetails> {
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();
  final StreamController<List<TodayModel>> _reportStream =
      StreamController<List<TodayModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  String error = '';
  double screenHeight = 0;
  double screenWidth = 0;

  // String _month = DateFormat('MMMM').format(DateTime.now());
  // String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

  Future<void> exportToExcel(List<EstabTodayModel> filteredProducts) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow(
        ['Email', 'Last Name', 'In-AM', 'Out-AM', 'In-PM', 'Out-PM', 'Date']);

    // Add data rows
    for (var product in filteredProducts) {
      sheet.appendRow([
        product.email,
        product.lname,
        product.time_in_am,
        product.time_out_am,
        product.time_in_pm,
        product.time_out_pm,
        product.date
      ]);
    }

    // Save the Excel file
    var file = 'dtr_report.xlsx';
    excel.save(fileName: file);
    OpenFile.open(file);
  }

  Future<void> monthly_report() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/monthly_report.php'),
        body: {
          'id': widget.id,
          'estab_id': widget.estab_id,
          'month': "none", // Pass selected month here
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EstabTodayModel> dtr =
            data.map((dtrData) => EstabTodayModel.fromJson(dtrData)).toList();
        _monthStream.add(dtr);
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

  String latestGrandTotalHours = "";
  Future<void> report() async {
    final response = await http.post(
      Uri.parse('${Server.host}users/student/monthly_report.php'),
      body: {'id': widget.id, 'estab_id': widget.estab_id, 'month': "all"},
    );
    // print("ID : ${Session.id}");
    // print("TEST : $_yearMonth");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // print("Response Data: $data");
      final List<TodayModel> dtr =
          data.map((dtrData) => TodayModel.fromJson(dtrData)).toList();
      setState(() {
        latestGrandTotalHours =
            dtr.isNotEmpty ? dtr.last.grand_total_hours_rendered : '';
      });

      // Add the list of classmates to the stream
      _reportStream.add(dtr);
      // generatePDFReport(dtr);
    } else {
      // print("Failed to load data. Status Code: ${response.statusCode}");
      setState(() {
        error = 'Failed to load data';
      });
    }
  }

  Future<void> refreshData() async {
    monthly_report();
  }

  @override
  void initState() {
    super.initState();
    monthly_report();
    report();
  }

  @override
  void dispose() {
    super.dispose();
    _monthStream.close();
    _reportStream.close();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Consumer<UserRole>(builder: (context, user, child) {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshData,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<EstabTodayModel>>(
                  stream: _monthStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final snap2 = snapshot.data!;
                      if (snap2.isEmpty) {
                        return const Center(child: Text("NO DATA THIS MONTH"));
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: PaginatedDataTable(
                                      header: ListTile(
                                        leading: Text(
                                          latestGrandTotalHours == ""
                                              ? ""
                                              : "Hours rendered: $latestGrandTotalHours hours",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        trailing: MaterialButton(
                                          color: Colors.blue,
                                          onPressed: () {
                                            exportToExcel(snap2);
                                          },
                                          child: const Text(
                                            'Export to Excel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "NexaBold",
                                            ),
                                          ),
                                        ),
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('Name')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Time-In AM')),
                                        DataColumn(label: Text('Time-Out AM')),
                                        DataColumn(label: Text('Time-In PM')),
                                        DataColumn(label: Text('Time-Out PM')),
                                      ],
                                      source: DTRDataSource(
                                          snap2.cast<EstabTodayModel>()),
                                      rowsPerPage: 5,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "In-range - within the 5 meter radius"),
                                      Text(
                                          "Outside range - away from the 5 meter radius"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError || error.isNotEmpty) {
                      return Center(
                        child: Text(
                          error.isNotEmpty ? error : 'Failed to load data',
                          style: const TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class DTRDataSource extends DataTableSource {
  final List<EstabTodayModel> _data;
  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  DTRDataSource(this._data);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }
    final dtr = _data[index];
    double INAMLAT = double.parse(dtr.in_am_lat);
    double INAMLONG = double.parse(dtr.in_am_long);

    double OUTAMLAT = double.parse(dtr.out_am_lat);
    double OUTAMLONG = double.parse(dtr.out_am_long);

    double INPMLAT = double.parse(dtr.in_pm_lat);
    double INPMLONG = double.parse(dtr.in_pm_long);

    double OUTPMLAT = double.parse(dtr.out_pm_lat);
    double OUTPMLONG = double.parse(dtr.out_pm_long);

    double estabLat = double.parse(dtr.latitude);
    double estabLong = double.parse(dtr.longitude);

    var distanceA = calculateDistance(INAMLAT, INAMLONG, estabLat, estabLong);
    var distanceB = calculateDistance(OUTAMLAT, OUTAMLONG, estabLat, estabLong);
    var distanceC = calculateDistance(INPMLAT, INPMLONG, estabLat, estabLong);
    var distanceD = calculateDistance(OUTPMLAT, OUTPMLONG, estabLat, estabLong);

    // //  Calculate distance between dragged position and circle center
    // double distanceA = Geolocator.distanceBetween(
    //   INAMLAT,
    //   INAMLONG,
    //   double.parse(dtr.latitude),
    //   double.parse(dtr.longitude),
    // );

    return DataRow(
      cells: [
        DataCell(Text(dtr.lname)),
        DataCell(
          Text(
            DateFormat('EE, dd MMM yyyy').format(
              DateFormat('yyyy-MM-dd').parse(dtr.date),
            ),
          ),
        ),
        DataCell(Row(
          children: [
            Text(
              dtr.time_in_am == defaultValue
                  ? defaultT
                  : DateFormat('hh:mm a').format(
                      DateFormat('hh:mm:ss').parse(
                        dtr.time_in_am,
                      ),
                    ),
            ),
            Text(
                distanceA > 5
                    ? "  / Outside range"
                    : distanceA < 0
                        ? ""
                        : " / In-range",
                style: TextStyle(
                    color: distanceA > 5 ? Colors.orange : Colors.blue))
          ],
        )),
        DataCell(Row(
          children: [
            Text(
              dtr.time_out_am == defaultValue
                  ? defaultT
                  : DateFormat('hh:mm a').format(
                      DateFormat('hh:mm:ss').parse(
                        dtr.time_out_am,
                      ),
                    ),
            ),
            Text(
                distanceB > 5
                    ? "  / Outside range"
                    : distanceB < 0
                        ? ""
                        : " / In-range",
                style: TextStyle(
                    color: distanceA > 5 ? Colors.orange : Colors.blue))
          ],
        )),
        DataCell(Row(
          children: [
            Text(
              dtr.time_in_pm == defaultValue
                  ? defaultT
                  : DateFormat('hh:mm a').format(
                      DateFormat('hh:mm:ss').parse(
                        dtr.time_in_pm,
                      ),
                    ),
            ),
            Text(
                distanceC > 5
                    ? "  / Outside range"
                    : distanceC < 0
                        ? ""
                        : " / In-range",
                style: TextStyle(
                    color: distanceA > 5 ? Colors.orange : Colors.blue))
          ],
        )),
        DataCell(Row(
          children: [
            Text(
              dtr.time_out_pm == defaultValue
                  ? defaultT
                  : DateFormat('hh:mm a').format(
                      DateFormat('hh:mm:ss').parse(
                        dtr.time_out_pm,
                      ),
                    ),
            ),
            Text(
                distanceD > 5
                    ? "  / Outside range"
                    : distanceD < 0
                        ? ""
                        : " / In-range",
                style: TextStyle(
                    color: distanceA > 5 ? Colors.orange : Colors.blue))
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
