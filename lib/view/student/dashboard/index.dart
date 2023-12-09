import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/controller/User.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:attendance_nmsct/view/student/dashboard/card.dart';
import 'package:attendance_nmsct/widgets/bottomsheet.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:flutter/material.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:http/http.dart' as http;

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({
    super.key,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StreamController<UserModel> _userStreamController =
      StreamController<UserModel>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<dynamic>? classData;
  List<dynamic>? roomData;
  String id = "";
  Future<void> _refreshData() async {
    fetchUser(_userStreamController);
  }

  @override
  void initState() {
    super.initState();
    fetchUserAndData();
  }

  Future<void> fetchUserAndData() async {
    await fetchUser(_userStreamController);
    await fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('${Server.host}pages/student/class_room.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        classData = data['class_data'];
        roomData = data['room_data'];
      });
    } else {
      print('Failed to fetch data: ${response.reasonPhrase}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _userStreamController.close();
  }

  void refresh() {
    _refreshIndicatorKey.currentState?.show(); // Show the refresh indicator
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: fetchUserAndData,
      child: StreamBuilder<UserModel>(
        stream: _userStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;

            if (user.section_id == "null" && user.establishment_id == "null") {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    bottomsheetJoin(context, user.role, user.section_name,
                        user.establishment_name,
                        refreshCallback: _refreshData);
                  },
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: ListView(
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          const Duck(),
                          Text("No Section or Establishment !",
                              style: Style.duck),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    bottomsheetJoin(context, user.role, user.section_name,
                        user.establishment_name,
                        refreshCallback: _refreshData);
                  },
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: ListView(
                  children: [
                    user.establishment_id != "null"
                        ? DashCard(
                            id: user.establishment_id,
                            name: user.establishment_name,
                            path: "room",
                            refreshCallback: _refreshData)
                        : const SizedBox(),
                    user.section_id != "null"
                        ? DashCard(
                            id: user.section_id,
                            name: user.section_name,
                            path: "class",
                            refreshCallback: _refreshData)
                        : const SizedBox(),
                  ],
                ),
              );
            }
          } else {
            return Scaffold(
              body: ListView(
                children: [
                  Visibility(
                    visible: classData == null && roomData == null,
                    child: RefreshIndicator(
                      onRefresh: fetchUserAndData,
                      child: CardSkeleton(
                        isCircularImage: true,
                        isBottomLinesActive: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
