import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/AdminModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AdminList extends StatefulWidget {
  const AdminList({super.key});

  @override
  State<AdminList> createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  List<AdminModel> interns = [];
  void fetchInterns() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/admin/all_admin.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        interns = data
            .map((classmateData) => AdminModel.fromJson(classmateData))
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
  void initState() {
    super.initState();
    fetchInterns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Admin List'),
        centerTitle: true,
      ),
      body: interns.isNotEmpty
          ? Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    // controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Full Name')),
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
                                            classmate.email,
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
                                    classmate.lname + " " + classmate.fname,
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
              ? Center(child: CircularProgressIndicator())
              : Center(child: Text("Error fetching data")),
    );
  }
}
