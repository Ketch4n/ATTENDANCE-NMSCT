import 'dart:async';
import 'package:attendance_nmsct/src/components/confirmation_dialog.dart';
import 'package:attendance_nmsct/src/components/page_header.dart';
import 'package:attendance_nmsct/src/components/show_dialog.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';

import 'package:attendance_nmsct/src/components/dialog/add_new_button.dart';
import 'package:attendance_nmsct/src/view/school_year/functions/delete_school_year.dart';
import 'package:attendance_nmsct/src/view/school_year/functions/fetch_all.dart';
import 'package:attendance_nmsct/src/view/school_year/model/school_year_model.dart';
import 'package:attendance_nmsct/src/view/school_year/school_year_page_add.dart';
import 'package:attendance_nmsct/src/view/school_year/school_year_page_edit.dart';
import 'package:flutter/material.dart';

class SchoolYearPage extends StatefulWidget {
  const SchoolYearPage({super.key});

  @override
  State<SchoolYearPage> createState() => _SchoolYearPageState();
}

class _SchoolYearPageState extends State<SchoolYearPage> {
  final StreamController<List<SchoolYearModel>> _schoolYearStream =
      StreamController<List<SchoolYearModel>>();

  void _fetchSchoolYear() async {
    await getSchoolYear(_schoolYearStream);
  }

  @override
  void initState() {
    super.initState();
    _fetchSchoolYear();
  }

  @override
  void dispose() {
    _schoolYearStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 810,
          ),
          child: Column(
            children: [
              indexPagesHeader("School Year"),
              Expanded(
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        addNewButton(context,
                            SchoolYearPageAdd(reload: _fetchSchoolYear)),
                        Expanded(
                          child: StreamBuilder<List<SchoolYearModel>>(
                            stream: _schoolYearStream.stream,
                            builder: (context, snapshot) {
                              List<SchoolYearModel> school =
                                  snapshot.data ?? [];
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No school year available.'));
                              } else {
                                return ListView.builder(
                                  itemCount: school.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Card(
                                        child: ListTile(
                                          leading: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.blue),
                                            child: const Icon(
                                              Icons.calendar_month,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Center(
                                            child: Text(
                                              school[index].year,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  controller.sy.text =
                                                      school[index].year;

                                                  showCustomDialog(
                                                      context,
                                                      SchoolYearPageEdit(
                                                          id: school[index].id,
                                                          reload: () =>
                                                              _fetchSchoolYear()));
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  const title =
                                                      'Delete School Year';
                                                  const content =
                                                      'Are you sure you want to delete this school year?';
                                                  confirmationDialog(
                                                      context,
                                                      title,
                                                      content,
                                                      () => deleteSchoolYear(
                                                            context,
                                                            school[index].id,
                                                          ).then((value) =>
                                                              _fetchSchoolYear()));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
