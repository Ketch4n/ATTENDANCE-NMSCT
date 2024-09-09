import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/AbsentModel.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AbsentRecordTab extends StatefulWidget {
  const AbsentRecordTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AbsentRecordTab> createState() => _AbsentRecordTabState();
}

class _AbsentRecordTabState extends State<AbsentRecordTab> {
  final StreamController<List<AbsentModel>> _absentController =
      StreamController<List<AbsentModel>>();
  late final TextEditingController _searchController;
  Future<void> streamAccomplishemnt(absentController) async {
    try {
      final purpose = Session.role == "Intern" ? "Intern" : "Estab";
      final response = await http.post(
        Uri.parse('${Server.host}users/student/view_absent.php'),
        body: {
          'student_id': Session.id,
          'section_id': widget.ids,
          'status': 'Record',
          'purpose': purpose
        },
      );
      // print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        // yield jsonList.map((json) => AbsentModel.fromJson(json)).toList();
        final List<AbsentModel> absent = jsonList
            .map((absentData) => AbsentModel.fromJson(absentData))
            .toList();
        absentController.add(absent); // Add data to the stream
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
      // You might want to display an error message to the user
    }
  }

  List filteredRows(List<AbsentModel> products) {
    String query = _searchController.text.toLowerCase();
    // Filter the products based on the search query
    List<AbsentModel> filteredProducts = products.where((product) {
      return product.id.toLowerCase().contains(query) ||
          product.lname!.toLowerCase().contains(query) ||
          product.reason.toLowerCase().contains(query) ||
          product.status.toLowerCase().contains(query) ||
          product.email!.toLowerCase().contains(query) ||
          product.date.toLowerCase().contains(query);
    }).toList();
    // Build the DataRow widgets for the filtered products
    return filteredProducts.toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    streamAccomplishemnt(_absentController);
  }

  @override
  void dispose() {
    super.dispose();
    _absentController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<AbsentModel>>(
              stream: _absentController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  List<AbsentModel>? data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'No records',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  } else {
                    data = filteredRows(data).cast<AbsentModel>();
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              // Filter the data based on the search query
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final AbsentModel absent = data![index];

                                  return Container(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            index == snapshot.data!.length - 1
                                                ? 70.0
                                                : 0),
                                    child: TimelineTile(
                                      isFirst: index == 0,
                                      isLast:
                                          index == snapshot.data!.length - 1,
                                      alignment: TimelineAlign.start,
                                      indicatorStyle: IndicatorStyle(
                                        width: 20,
                                        color: absent.status == 'Pending'
                                            ? Colors.blue
                                            : absent.status == 'Approved'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      endChild: GestureDetector(
                                        // onLongPress: () => _showUpdateDeleteModal(record),
                                        child: Card(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ListTile(
                                                // leading: Text(
                                                //     "Absent Date: " + absent.date),
                                                title: Row(
                                                  children: [
                                                    Text(
                                                        "Absent: ${absent.date}"),
                                                    Text(
                                                      "  (${absent.status})",
                                                      style: TextStyle(
                                                        color: absent.status ==
                                                                'Pending'
                                                            ? Colors.blue
                                                            : absent.status ==
                                                                    'Approved'
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Session.role == "Intern"
                                                          ? const SizedBox()
                                                          : Text(
                                                              "From: ${absent.lname!}"),
                                                      Session.role == "Intern"
                                                          ? const SizedBox()
                                                          : Text(absent.email!),
                                                      Text(
                                                          "Reason of absent: ${absent.reason}"),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return Expanded(
                    child: CardPageSkeleton(),
                  );
                }
              }),
        ),
      ],
    ));
  }
}
