import 'dart:async';
import 'dart:convert';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/SectionModel.dart';
import 'package:attendance_nmsct/view/administrator/create.dart';
import 'package:attendance_nmsct/view/administrator/dash_card.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final StreamController<List<SectionModel>> _sectionStreamController =
      StreamController<List<SectionModel>>();
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
      Uri.parse('${Server.host}users/admin/section.php'),
      body: {
        'id': userId,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<SectionModel> sections = data
          .map((sectionData) => SectionModel.fromJson(sectionData))
          .toList();
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: fetchData,
      child: StreamBuilder<List<SectionModel>>(
        stream: _sectionStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final sect2 = snapshot.data!;
            // final List<SectionModel> sect = snapshot.data!;
            // final SectionModel sec2 = sect2[0];
            // final user = snapshot.data!;
            if (sect2 == 'null' || sect2.isEmpty) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    bottomsheet(context, uRole, uId);
                  },
                  child: const Icon(Icons.add),
                ),
                body: ListView(
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          const Duck(),
                          Text(
                              uRole == 'Admin'
                                  ? "No Section Found !"
                                  : "No registered Establishment !",
                              style: Style.duck),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Switch Account"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final SectionModel sec2 = sect2[0];

              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    bottomsheet(context, uRole, uId);
                  },
                  child: const Icon(Icons.add),
                ),
                body: ListView.builder(
                    itemCount: sect2.length,
                    itemBuilder: (context, index) {
                      final SectionModel sec = sect2[index];
                      return GlobalDashCard(
                          id: sec.id,
                          uid: sec.admin_id,
                          name: sec.section_name,
                          code: sec.code,
                          path: uRole == 'Admin' ? "class" : "room",
                          refreshCallback: _refreshData);
                    }),
              );
            }
          } else {
            return CardSkeleton(
                isCircularImage: true, isBottomLinesActive: true);
          }
        },
      ),
    );
  }

  Future bottomsheet(
    BuildContext context,
    String role,
    String adminId,
  ) async {
    showAdaptiveActionSheet(
        context: context,
        title: const Text('Create'),
        androidBorderRadius: 20,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text(
                role == "Admin" ? 'Section' : 'Establishment',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "MontserratBold"),
              ),
              onPressed: (context) {
                String purpose = role == "Admin" ? 'Section' : 'Establishment';
                Navigator.of(context).pop(false);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateClassRoom(
                        role: role,
                        admin_id: adminId,
                        purpose: purpose,
                        refreshCallback: _refreshData)));
              }),
        ]);
  }
}
