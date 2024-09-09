import 'dart:async';
import 'dart:convert';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/EstabModel.dart';
import 'package:attendance_nmsct/src/view/administrator/create.dart';
import 'package:attendance_nmsct/src/view/administrator/dash_card.dart';
import 'package:attendance_nmsct/src/components/duck.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class EstabDashboard extends StatefulWidget {
  const EstabDashboard({
    super.key,
  });

  @override
  State<EstabDashboard> createState() => _EstabDashboardState();
}

class _EstabDashboardState extends State<EstabDashboard> {
  final StreamController<List<EstabModel>> _sectionStreamController =
      StreamController<List<EstabModel>>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<dynamic>? classData;
  List<dynamic>? roomData;
  String uId = "";
  String uRole = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _refreshData() async {
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userRole = prefs.getString('userRole');
    setState(() {
      uId = userId!;
      uRole = userRole!;
    });
    final response = await http.post(
      Session.role == "Administrator"
          ? Uri.parse('${Server.host}users/establishment/estab.php')
          : Uri.parse('${Server.host}users/establishment/estab_nmscst.php'),
      body: {
        'id': Session.id,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<EstabModel> sections =
          data.map((sectionData) => EstabModel.fromJson(sectionData)).toList();
      _sectionStreamController.add(sections);
    } else {
      print('Failed to fetch data: ${response.reasonPhrase}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _sectionStreamController.close();
  }

  void refresh() {
    _refreshIndicatorKey.currentState?.show(); // Show the refresh indicator
  }
  //  Future<void> fetchData() async {
  //   // Replace with the URL of your PHP script
  //   final response = await http.get( Uri.parse('${Server.host}pages/student/class_room.php'));

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);

  //     setState(() {
  //       classData = data['class_data'];
  //       roomData = data['room_data'];
  //     });

  //     // Get the total number of arrays
  //     int totalClassData = classData.length;
  //     int totalRoomData = roomData.length;

  //     int totalArrays = totalClassData + totalRoomData;

  //     print('Total class data arrays: $totalClassData');
  //     print('Total room data arrays: $totalRoomData');
  //   } else {
  //     print('Failed to fetch data');
  //   }
  // }
  // List classData = [];
  // List roomData = [];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: fetchData,
      child: StreamBuilder<List<EstabModel>>(
        stream: _sectionStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final sect2 = snapshot.data!;
            // final List<EstabModel> sect = snapshot.data!;
            // final EstabModel sec2 = sect2[0];
            // final user = snapshot.data!;
            if (sect2 == 'null' || sect2.isEmpty) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    bottomsheet(uRole, uId);
                  },
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Duck(),
                          Text(
                              uRole == 'Admin'
                                  ? "No Section Found !"
                                  : "No registered Establishment !",
                              style: Style.duck),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // final EstabModel sec2 = sect2[0];

              return Scaffold(
                  floatingActionButton: sect2.isEmpty
                      ? FloatingActionButton(
                          onPressed: () async {
                            bottomsheet(uRole, uId);
                          },
                          child: const Icon(Icons.add),
                        )
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  body: Session.role == "NMSCST"
                      ? Wrap(
                          spacing: 0.0, // Adjust spacing as needed
                          runSpacing: 10.0, // Adjust run spacing as needed
                          children: sect2.map((EstabModel sec) {
                            return GlobalDashCard(
                              id: sec.id.toString(),
                              // uid: sec.creator_email,
                              name: sec.establishment_name,
                              // code: sec.code,
                              path: uRole == 'Admin' ? "class" : "room",
                              refreshCallback: _refreshData,
                            );
                          }).toList(),
                        )
                      : ListView.builder(
                          itemCount: sect2.length,
                          itemBuilder: (BuildContext context, int index) {
                            EstabModel sec = sect2[index];
                            return GlobalDashCard(
                              id: sec.id.toString(),
                              // uid: sec.creator_email,
                              name: sec.establishment_name,
                              // code: sec.code,
                              path: uRole == 'Admin' ? "class" : "room",
                              refreshCallback: _refreshData,
                            );
                          },
                        ));
            }
          } else {
            return CardSkeleton(
                isCircularImage: true, isBottomLinesActive: true);
          }
        },
      ),
    );
  }

  Future bottomsheet(String role, String adminId) async {
    showAdaptiveActionSheet(
        context: context,
        title: const Text('Create'),
        androidBorderRadius: 20,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text(
                uRole == "Admin" ? 'Section' : 'Establishment',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "MontserratBold"),
              ),
              onPressed: (context) {
                String purpose = uRole == "Admin" ? 'Section' : 'Establishment';
                Navigator.of(context).pop(false);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateClassRoom(
                        role: role,
                        // admin_id: adminId,
                        purpose: purpose,
                        refreshCallback: _refreshData)));
              }),
        ]);
  }
}
