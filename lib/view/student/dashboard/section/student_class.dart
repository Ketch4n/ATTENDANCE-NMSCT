import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/ClassModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentClass extends StatefulWidget {
  const StudentClass({super.key, required this.ids, required this.name});
  final String ids;
  final String name;
  @override
  State<StudentClass> createState() => _StudentClassState();
}

class _StudentClassState extends State<StudentClass> {
  final StreamController<List<ClassModel>> _classmateStreamController =
      StreamController<List<ClassModel>>();
  // Future<void> _refreshData() async {
  //   await fetchUser(_userStreamController);
  // }
  String yourID = "";
  String admin_ID = "";
  String admin_name = "";
  String admin_email = "";

  Future<void> fetchClassmates(classmateStreamController) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    setState(() {
      yourID = userId!;
    });
    final response = await http.post(
      Uri.parse('${Server.host}users/student/class.php'),
      body: {'section_id': widget.ids},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<ClassModel> classmates = data
          .map((classmateData) => ClassModel.fromJson(classmateData))
          .toList();
      setState(() {
        admin_ID = classmates[0].admin_id;
        admin_name = classmates[0].admin_name;
        admin_email = classmates[0].admin_email;
      });

      // Add the list of classmates to the stream
      classmateStreamController.add(classmates);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClassmates(_classmateStreamController);
  }

  @override
  void dispose() {
    super.dispose();
    _classmateStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                    borderRadius: Style.borderRadius,
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
                    Text(admin_name, style: const TextStyle(fontSize: 18)),
                    Text(
                      admin_email,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
          ),
          const ListTile(
            title: Text(
              "Classmates",
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
          StreamBuilder<List<ClassModel>>(
              stream: _classmateStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<ClassModel> classmates = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: classmates.length,
                        itemBuilder: (context, index) {
                          final ClassModel classmate = classmates[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: Style.borderRadius,
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
                                          classmate.student_id == yourID
                                              ? "${classmate.name} (You)"
                                              : classmate.name,
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                        classmate.email,
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
                    child: Text("No classmates found"),
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
