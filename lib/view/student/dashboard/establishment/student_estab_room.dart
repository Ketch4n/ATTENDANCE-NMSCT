import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/RoomModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentEstabRoom extends StatefulWidget {
  const StudentEstabRoom({super.key, required this.ids, required this.name});
  final String ids;
  final String name;
  @override
  State<StudentEstabRoom> createState() => _StudentEstabRoomState();
}

class _StudentEstabRoomState extends State<StudentEstabRoom> {
  final StreamController<List<RoomModel>> _roomateStreamController =
      StreamController<List<RoomModel>>();

  // Future<void> _refreshData() async {
  //   await fetchUser(_userStreamController);
  // }
  String yourID = "";
  String creator_ID = "";
  String creator_name = "";
  String creator_email = "";
  Future<void> fetchroomates(roomateStreamController) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    setState(() {
      yourID = userId!;
    });
    final response = await http.post(
      Uri.parse('${Server.host}users/student/room.php'),
      body: {'establishment_id': widget.ids},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<RoomModel> roomates =
          data.map((roomateData) => RoomModel.fromJson(roomateData)).toList();
      setState(() {
        creator_ID = roomates[0].creator_id;
        creator_name = roomates[0].creator_name;
        creator_email = roomates[0].creator_email;
      });

      // Add the list of roomates to the stream
      roomateStreamController.add(roomates);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchroomates(_roomateStreamController);
  }

  @override
  void dispose() {
    super.dispose();
    _roomateStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Administrator",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontFamily: "MontserratBold"),
            ),
            subtitle: Divider(
              color: Colors.blue,
              thickness: 2,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                ClipRRect(
                    borderRadius: Style.radius50,
                    child: Image.asset(
                      "assets/images/estab.png",
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator_name == Session.name
                          ? '$creator_name (You)'
                          : creator_name,
                    ),
                    Text(
                      creator_email,
                    )
                  ],
                )
              ],
            ),
          ),
          const ListTile(
            title: Text(
              "Interns",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontFamily: "MontserratBold"),
            ),
            subtitle: Divider(
              color: Colors.blue,
              thickness: 2,
            ),
          ),
          StreamBuilder<List<RoomModel>>(
              stream: _roomateStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<RoomModel> roomates = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: roomates.length,
                        itemBuilder: (context, index) {
                          final RoomModel roomate = roomates[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: Style.radius50,
                                      child: Image.asset(
                                        "assets/images/admin.png",
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          roomate.student_id == yourID
                                              ? "${roomate.name} (You)"
                                              : roomate.name,
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                        roomate.email,
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text("No Interns"),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
