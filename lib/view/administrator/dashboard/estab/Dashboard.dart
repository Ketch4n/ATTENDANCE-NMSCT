import 'dart:convert';

import 'package:attendance_nmsct/view/administrator/dashboard/estab/all_students.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/index.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';

class DashBoardEstab extends StatefulWidget {
  const DashBoardEstab({super.key});

  @override
  State<DashBoardEstab> createState() => _DashBoardEstabState();
}

class _DashBoardEstabState extends State<DashBoardEstab> {
  late String count = "";
  late String count_estab = "";
  Future<void> fetchinterns() async {
    final response = await http.get(
      Uri.parse('${Server.host}users/establishment/count.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        count = responseData['total_users'];
      });
      // Extract the count of users
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchestab() async {
    final response = await http.get(
      Uri.parse('${Server.host}users/establishment/count_estab.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        count_estab = responseData['total_estab'];
      });
      // Extract the count of users
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();

    fetchinterns();
    fetchestab();
  }

  double screenHeight = 0;
  double screenWidth = 0;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Wrap(
          spacing: 8.0, // spacing between cards
          runSpacing: 8.0, // spacing between rows
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EstabDashboard())),
              child: Container(
                height: screenHeight / 5,
                width: screenWidth / 2.5,
                decoration: BoxDecoration(color: Colors.green),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'List of All Establishments',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Text(
                        count_estab,
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: screenHeight / 5,
                width: screenWidth / 2.5,
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'List of All Students',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Text(
                        count,
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
