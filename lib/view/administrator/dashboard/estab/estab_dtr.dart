import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/model/EstabTodayModel.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

class EstabDTR extends StatefulWidget {
  const EstabDTR({super.key, required this.id, required this.name});
  final String id;
  final String name;

  @override
  State<EstabDTR> createState() => _EstabDTRState();
}

class _EstabDTRState extends State<EstabDTR> {
  final StreamController<List<EstabTodayModel>> _monthStream =
      StreamController<List<EstabTodayModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late TextEditingController _searchController;
  String defaultValue = '00:00:00';
  String defaultT = '--/--';
  String error = '';
  double screenHeight = 0;
  double screenWidth = 0;

  String _month = DateFormat('MMMM').format(DateTime.now());
  String _yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List filteredRows(List<EstabTodayModel> products) {
    String query = _searchController.text.toLowerCase();
    // Filter the products based on the search query
    List<EstabTodayModel> filteredProducts = products.where((product) {
      return product.id.toString().toLowerCase().contains(query) ||
          product.lname!.toLowerCase().contains(query) ||
          product.time_in_am.toLowerCase().contains(query) ||
          product.time_out_am.toLowerCase().contains(query) ||
          product.time_in_pm.toLowerCase().contains(query) ||
          product.time_out_pm.toLowerCase().contains(query) ||
          product.date.toLowerCase().contains(query);
    }).toList();
    // Build the DataRow widgets for the filtered products
    return filteredProducts.toList();
  }

  Future<void> exportToExcel(filteredProducts) async {
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
    var file = '$sheet.xlsx';
    excel.save(fileName: file);
  }

  Future<void> monthly_report(monthStream) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/monthly_report.php'),
        body: {
          'id': widget.id,
          'month': _yearMonth,
        },
      );
      print("TEST : $_yearMonth");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<EstabTodayModel> dtr =
            data.map((dtrData) => EstabTodayModel.fromJson(dtrData)).toList();
        // Add the list of classmates to the stream
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

  Future refreshData() async {
    monthly_report(_monthStream);
  }

  // Function to filter the data based on the search query
  List<EstabTodayModel> filterData(List<EstabTodayModel> data, String query) {
    if (query.isEmpty) {
      return data;
    }
    return data.where((dtr) {
      return dtr.lname!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    monthly_report(_monthStream);

    _searchController = TextEditingController();
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
    return Consumer<UserRole>(builder: (context, user, child) {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshData,
        child: Scaffold(
          body: Column(
            children: [
              Session.role == "Administrator"
                  ? MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2099),
                        );

                        if (month != null) {
                          setState(() {
                            _month = DateFormat('MMMM').format(month);
                            _yearMonth = DateFormat('yyyy-MM').format(month);
                          });
                        }
                        monthly_report(_monthStream);
                      },
                      child: Text(
                        _month,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "NexaBold",
                          // fontSize: screenWidth / 15,
                        ),
                      ),
                    )
                  : const SizedBox(),
              Session.role == "Administrator"
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          // Filter the data based on the search query
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          labelText: 'Search by Name',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Expanded(
                child: StreamBuilder<List<EstabTodayModel>>(
                    stream: _monthStream.stream,
                    builder: (context, snapshot) {
                      final snap2 = snapshot.data!;
                      final snap = filteredRows(snap2);
                      if (snapshot.hasData) {
                        if (snap.isEmpty) {
                          return const Center(
                              child: Text("NO DATA THIS MONTH"));
                        } else {
                          return user.role == "NMSCST"
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: PaginatedDataTable(
                                            header: ListTile(
                                              leading: const Text(
                                                'DTR Records',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              trailing: MaterialButton(
                                                color: Colors.green,
                                                onPressed: () {
                                                  exportToExcel(snap);
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
                                              DataColumn(
                                                  label: Text('Time-In AM')),
                                              DataColumn(
                                                  label: Text('Time-Out AM')),
                                              DataColumn(
                                                  label: Text('Time-In PM')),
                                              DataColumn(
                                                  label: Text('Time-Out PM')),
                                            ],
                                            source: DTRDataSource(
                                                snap.cast<EstabTodayModel>()),
                                            rowsPerPage:
                                                5, // Adjust as per your requirement
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListView.builder(
                                    itemCount: snap.length,
                                    itemBuilder: (context, index) {
                                      final EstabTodayModel dtr = snap[index];

                                      return
                                          // DateFormat('MMMM').format(
                                          //             DateFormat('yyyy-mm-dd').parse(dtr.date)) ==
                                          //         _month
                                          //     ?
                                          GestureDetector(
                                        onTap: () {
                                          // showReport(context, dtr.time_in_am,
                                          //     dtr.time_in_am);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: index > 0 ? 12 : 0,
                                              bottom: 6,
                                              left: 6,
                                              right: 6),
                                          height: 100,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 20,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(80),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(dtr.lname!,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          DateFormat('EE')
                                                              .format(DateFormat(
                                                                      'yyyy-mm-dd')
                                                                  .parse(dtr
                                                                      .date)),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  "NexaBold",
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          DateFormat('dd ')
                                                              .format(DateFormat(
                                                                      'yyyy-mm-dd')
                                                                  .parse(dtr
                                                                      .date)),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  "NexaBold",
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Time-In",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "NexaRegular",
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    Text(
                                                      dtr.time_in_am ==
                                                              defaultValue
                                                          ? defaultT
                                                          : DateFormat('hh:mm ')
                                                              .format(DateFormat(
                                                                      'hh:mm:ss')
                                                                  .parse(dtr
                                                                      .time_in_am))
                                                      //             +
                                                      // dtr.in_am
                                                      ,
                                                      style: const TextStyle(
                                                        fontFamily: "NexaBold",
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Time-In",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "NexaRegular",
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    Text(
                                                      dtr.time_in_pm ==
                                                              defaultValue
                                                          ? defaultT
                                                          : DateFormat('hh:mm ')
                                                              .format(DateFormat(
                                                                      'hh:mm:ss')
                                                                  .parse(dtr
                                                                      .time_in_pm))
                                                      //              +
                                                      // dtr.in_pm
                                                      ,
                                                      style: const TextStyle(
                                                        fontFamily: "NexaBold",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Time-Out",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "NexaRegular",
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                    Text(
                                                      dtr.time_out_am ==
                                                              defaultValue
                                                          ? defaultT
                                                          : DateFormat('hh:mm ')
                                                              .format(DateFormat(
                                                                      'hh:mm:ss')
                                                                  .parse(dtr
                                                                      .time_out_am))
                                                      //              +
                                                      // dtr.out_am
                                                      ,
                                                      style: const TextStyle(
                                                        fontFamily: "NexaBold",
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Time-Out",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "NexaRegular",
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                    Text(
                                                      dtr.time_out_pm ==
                                                              defaultValue
                                                          ? defaultT
                                                          : DateFormat('hh:mm ')
                                                              .format(DateFormat(
                                                                      'hh:mm:ss')
                                                                  .parse(dtr
                                                                      .time_out_pm))
                                                      //             +
                                                      // dtr.out_pm
                                                      ,
                                                      style: const TextStyle(
                                                        fontFamily: "NexaBold",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                          // : const SizedBox()
                                          ;
                                    },
                                  ),
                                );
                        }
                      } else if (snapshot.hasError || error.isNotEmpty) {
                        return Center(
                          child: Text(
                            error.isNotEmpty ? error : 'Failed to load data',
                            style: const TextStyle(
                                color: Colors
                                    .red), // You can adjust the error message style
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
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
        DataCell(Text(dtr.lname!)),
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
                  DateFormat('hh:mm:ss').parse(dtr.time_in_am),
                ),
        )),
        DataCell(Text(
          dtr.time_out_am == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(dtr.time_out_am),
                ),
        )),
        DataCell(Text(
          dtr.time_in_pm == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(dtr.time_in_pm),
                ),
        )),
        DataCell(Text(
          dtr.time_out_pm == defaultValue
              ? defaultT
              : DateFormat('hh:mm a').format(
                  DateFormat('hh:mm:ss').parse(dtr.time_out_pm),
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
