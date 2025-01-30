import 'dart:convert';
import 'package:attendance_nmsct/src/auth/signup.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/AdminModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/Courses.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  late Future<List<AdminModel>> _futureAdmins;

  @override
  void initState() {
    super.initState();
    _futureAdmins = fetchAdmins();
  }

  Future<List<AdminModel>> fetchAdmins() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/admin/all_faculty.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => AdminModel.fromJson(e)).toList();
      } else {
        throw Exception(
            'Error: ${response.statusCode}, Message: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faculty List'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<AdminModel>>(
          future: _futureAdmins,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final admins = snapshot.data!;
              return Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                return Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Signup(
                                    purpose: 'FACULTY',
                                    reload: () {
                                      setState(() {
                                        _futureAdmins = fetchAdmins();
                                      });
                                    },
                                  )));
                        },
                        icon: const Icon(Icons.add)),
                    _buildAdminTable(admins, provider),
                  ],
                );
              });
            } else {
              return Column(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Signup(
                                  purpose: 'FACULTY',
                                  reload: () {
                                    setState(() {
                                      _futureAdmins = fetchAdmins();
                                    });
                                  },
                                )));
                      },
                      icon: const Icon(Icons.add)),
                  const Center(child: Text('No data available')),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAdminTable(List<AdminModel> admins, DashboardProvider provider) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Student List')),
          ],
          rows: admins.map((admin) {
            return DataRow(
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
                      Text(
                        admin.email,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    "${admin.lname} ${admin.fname}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    admin.role,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CoursesPage(
                                  year: provider.selectedYearRange ??
                                      provider.defaultYear,
                                )));
                      }),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
