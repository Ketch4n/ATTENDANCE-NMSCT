import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/model/UnRegisteredModel.dart';

class UnregUsers extends StatefulWidget {
  const UnregUsers({super.key, required this.ids});
  final String ids;

  @override
  State<UnregUsers> createState() => _UnregUsersState();
}

class _UnregUsersState extends State<UnregUsers> {
  final StreamController<List<UnregmModel>> _unregStreamController =
      StreamController<List<UnregmModel>>();

  late String selected = '';
  late String lname = '';
  late String fname = '';
  late String id = '';

  @override
  void initState() {
    super.initState();
    fetchUnregistered(_unregStreamController);
  }

  @override
  void dispose() {
    super.dispose();
    _unregStreamController.close();
  }

  Future<void> fetchUnregistered(
      StreamController<List<UnregmModel>> unregStreamController) async {
    final response = await http.get(
      Uri.parse('${Server.host}users/admin/unregistered_students.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<UnregmModel> unreg = data
          .map((classmateData) => UnregmModel.fromJson(classmateData))
          .toList();

      unregStreamController.add(unreg);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> saveSelected() async {
    print('ID selected: $id');
    print('ESTAB ID selected: ${widget.ids}');

    final response = await http.post(
      Uri.parse('${Server.host}users/admin/join_estab_students.php'),
      body: {
        'student_id': id,
        'estab_id': widget.ids,
      },
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print('Response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving data. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            selected.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Stack(
                      children: [
                        Container(
                          height: 150,
                          width: 500,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name: $lname$fname",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Text(
                                  "Email: $selected",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton(
                                onPressed: () {
                                  saveSelected();
                                },
                                child: const Text("Save")))
                      ],
                    ),
                  ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "STUDENT WITH NO ESTABLISHMENTS YET",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            StreamBuilder<List<UnregmModel>>(
              stream: _unregStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<UnregmModel> unregStudents = snapshot.data!;
                  if (unregStudents.isEmpty) {
                    return const Text("No unregistered students");
                  } else {
                    return DropdownButton<UnregmModel>(
                      items: unregStudents.map((UnregmModel student) {
                        return DropdownMenuItem<UnregmModel>(
                          value: student,
                          child: Text(
                              '${student.fname} ${student.lname} (${student.email})'),
                        );
                      }).toList(),
                      onChanged: (UnregmModel? selectedStudent) {
                        setState(() {
                          selected = selectedStudent!.email.toString();
                          lname = selectedStudent.lname.toString();
                          fname = selectedStudent.fname.toString();
                          id = selectedStudent.id.toString();
                        });
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
