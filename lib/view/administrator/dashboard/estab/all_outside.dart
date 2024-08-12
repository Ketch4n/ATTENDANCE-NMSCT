// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/view/student/calculate_distance.dart';
import 'package:attendance_nmsct/view/student/location_label.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class AllOutsideRange extends StatefulWidget {
  const AllOutsideRange({
    super.key,
    required this.ids,
  });

  final List<String> ids;

  @override
  State<AllOutsideRange> createState() => _AllOutsideRangeState();
}

class _AllOutsideRangeState extends State<AllOutsideRange> {
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  String error = '';
  double screenHeight = 0;
  double screenWidth = 0;

  Future<void> exportToPDF(List<EstabTodayModel> filteredProducts) async {
    final pdf = pw.Document();

    // Add a page with a table of the data
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Email',
              'Last Name',
              'In-AM',
              'Out-AM',
              'In-PM',
              'Out-PM',
              'Date',
            ],
            data: filteredProducts.map((product) {
              return [
                product.email ?? '',
                product.lname ?? '',
                product.time_in_am ?? '',
                product.time_out_am ?? '',
                product.time_in_pm ?? '',
                product.time_out_pm ?? '',
                product.date ?? '',
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

  Future<void> monthly_report() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/all_outside.php'),
        body: {
          'ids': jsonEncode(widget.ids),
        },
      );
      print("TESTESTS${jsonEncode(widget.ids)}");

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

  Future<void> refreshData() async {
    monthly_report();
  }

  @override
  void initState() {
    super.initState();
    monthly_report();
  }

  @override
  void dispose() {
    super.dispose();
    _monthStream.close();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: refreshData,
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<EstabTodayModel>>(
                  stream: _monthStream.stream,
                  builder: (context, snapshot) {
                    final snap2 = snapshot.data ?? [];
                    if (snapshot.hasData) {
                      if (snap2.isEmpty) {
                        return const Center(child: Text("NO DATA THIS MONTH"));
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              MaterialButton(
                                color: Colors.redAccent,
                                onPressed: () {
                                  exportToPDF(snap2);
                                },
                                child: const Text(
                                  'Export to PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: PaginatedDataTable(
                                      columns: const [
                                        DataColumn(label: Text('Email')),
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
                                          "In-range - within the establishment meter radius"),
                                      Text(
                                          "Outside range - away from the establishment meter radius"),
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
      ),
    );
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
    double meterValue = double.parse(dtr.radius ?? '0');

    // double negative = -1.0;

    double INAMLAT = double.parse(dtr.in_am_lat ?? '0');
    double INAMLONG = double.parse(dtr.in_am_long ?? '0');

    double OUTAMLAT = double.parse(dtr.out_am_lat ?? '0');
    double OUTAMLONG = double.parse(dtr.out_am_long ?? '0');

    double INPMLAT = double.parse(dtr.in_pm_lat ?? '0');
    double INPMLONG = double.parse(dtr.in_pm_long ?? '0');

    double OUTPMLAT = double.parse(dtr.out_pm_lat ?? '0');
    double OUTPMLONG = double.parse(dtr.out_pm_long ?? '0');

    double estabLat = double.parse(dtr.latitude ?? '0');
    double estabLong = double.parse(dtr.longitude ?? '0');

    var distanceA = calculateDistance(INAMLAT, INAMLONG, estabLat, estabLong);
    var distanceB = calculateDistance(OUTAMLAT, OUTAMLONG, estabLat, estabLong);
    var distanceC = calculateDistance(INPMLAT, INPMLONG, estabLat, estabLong);
    var distanceD = calculateDistance(OUTPMLAT, OUTPMLONG, estabLat, estabLong);

    return DataRow(
      cells: [
        DataCell(Text(dtr.email ?? '')),
        DataCell(Text(dtr.lname ?? '')),
        DataCell(
          Text(
            DateFormat('EE, dd MMM yyyy').format(
              DateFormat('yyyy-MM-dd').parse(dtr.date ?? ''),
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
            LocationLabel(
              estabLat: estabLat,
              estabLong: estabLong,
              latitude: INAMLAT,
              longitude: INAMLONG,
              distance: distanceA,
              meter: meterValue,
            ),
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
            LocationLabel(
              estabLat: estabLat,
              estabLong: estabLong,
              latitude: OUTAMLAT,
              longitude: OUTAMLONG,
              distance: distanceB,
              meter: meterValue,
            ),
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
            LocationLabel(
              estabLat: estabLat,
              estabLong: estabLong,
              latitude: INPMLAT,
              longitude: INPMLONG,
              distance: distanceC,
              meter: meterValue,
            ),
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
            LocationLabel(
              estabLat: estabLat,
              estabLong: estabLong,
              latitude: OUTPMLAT,
              longitude: OUTAMLONG,
              distance: distanceD,
              meter: meterValue,
            ),
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
