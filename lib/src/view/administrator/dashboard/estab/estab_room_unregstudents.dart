import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/UnRegisteredModel.dart';

class UnregUsers extends StatefulWidget {
  const UnregUsers({super.key, required this.ids});
  final String ids;

  @override
  State<UnregUsers> createState() => _UnregUsersState();
}

class _UnregUsersState extends State<UnregUsers> {
  final StreamController<List<UnregmModel>> _unregStreamController =
      StreamController<List<UnregmModel>>();

  final List<UnregmModel> _selectedUsers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUnregistered(_unregStreamController);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _unregStreamController.close();
    _searchController.dispose();
  }

  Future<void> fetchUnregistered(
      StreamController<List<UnregmModel>> unregStreamController) async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/admin/unregistered_students.php'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Data received: $data');
        final List<UnregmModel> unreg = data
            .map((classmateData) => UnregmModel.fromJson(classmateData))
            .toList();

        unregStreamController.add(unreg);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      unregStreamController.addError(e);
    }
  }

  Future<void> saveSelected() async {
    final List<String> studentIds =
        _selectedUsers.map((user) => user.id).toList();

    final response = await http.post(
      Uri.parse('${Server.host}users/admin/join_estab_students.php'),
      body: {
        'student_ids': json.encode(studentIds),
        'estab_id': widget.ids,
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Response: ${response.body}');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      debugPrint('Response: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving data. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "STUDENT WITH NO ESTABLISHMENTS YET",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 500,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            _selectedUsers.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          saveSelected();
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
            StreamBuilder<List<UnregmModel>>(
              stream: _unregStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<UnregmModel> unregStudents = snapshot.data!
                      .where((student) =>
                          student.fname
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          student.lname
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          student.email
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();
                  if (unregStudents.isEmpty) {
                    return const Text("No unregistered students");
                  } else {
                    return Expanded(
                      child: ListView(
                        children: unregStudents.map((UnregmModel student) {
                          return CheckboxListTile(
                            title: Text(
                                '${student.fname} ${student.lname} (${student.email})'),
                            value: _selectedUsers.contains(student),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUsers.add(student);
                                } else {
                                  _selectedUsers.remove(student);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
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
