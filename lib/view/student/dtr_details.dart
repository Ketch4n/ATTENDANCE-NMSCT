import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/model/TodayModel.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/pdf.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/report.dart';
import 'package:excel/excel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDTRDetails extends StatefulWidget {
  const StudentDTRDetails({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

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

  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

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
    await excel.save(fileName: file);
    OpenFile.open(file);
  }

  Future<void> monthly_report() async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/monthly_report.php'),
        body: {
          'id': widget.id,
          'month': _yearMonth, // Pass selected month here
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
      body: {'id': widget.id, 'estab_id': "none", 'month': "all"},
    );
    print("ID : ${Session.id}");
    print("TEST : $_yearMonth");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Response Data: $data");
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
      print("Failed to load data. Status Code: ${response.statusCode}");
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
                                              : "Hours rendered: " +
                                                  latestGrandTotalHours +
                                                  " hours",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        trailing: MaterialButton(
                                          color: Colors.green,
                                          onPressed: () {
                                            exportToExcel(snap2);
                                          },
                                          child: Text(
                                            'Export to Excel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "NexaBold",
                                            ),
                                          ),
                                        ),
                                      ),
                                      columns: [
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
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError || error.isNotEmpty) {
                      return Center(
                        child: Text(
                          error.isNotEmpty ? error : 'Failed to load data',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
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
        DataCell(Text(
          dtr.time_in_am == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(
                    dtr.time_in_am + ' ' + dtr.in_am,
                  ),
                ),
        )),
        DataCell(Text(
          dtr.time_out_am == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(
                    dtr.time_out_am + ' ' + dtr.out_am,
                  ),
                ),
        )),
        DataCell(Text(
          dtr.time_in_pm == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(
                    dtr.time_in_pm + ' ' + dtr.in_pm,
                  ),
                ),
        )),
        DataCell(Text(
          dtr.time_out_pm == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(
                    dtr.time_out_pm + ' ' + dtr.out_pm,
                  ),
                ),
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
