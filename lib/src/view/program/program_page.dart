import 'dart:async';
import 'package:attendance_nmsct/src/components/confirmation_dialog.dart';
import 'package:attendance_nmsct/src/components/page_header.dart';
import 'package:attendance_nmsct/src/components/show_dialog.dart';
import 'package:attendance_nmsct/src/data/instance/controller_instance.dart';
import 'package:attendance_nmsct/src/view/program/functions/delete.dart';
import 'package:attendance_nmsct/src/view/program/functions/fetch_all.dart';
import 'package:attendance_nmsct/src/view/program/model/program_model.dart';
import 'package:attendance_nmsct/src/view/program/modules/add_new_button.dart';
import 'package:attendance_nmsct/src/view/program/program_edit.dart';
import 'package:flutter/material.dart';

class ProgramCoursePage extends StatefulWidget {
  const ProgramCoursePage({super.key});

  @override
  State<ProgramCoursePage> createState() => _ProgramCoursePageState();
}

class _ProgramCoursePageState extends State<ProgramCoursePage> {
  final StreamController<List<ProgramModel>> _programStream =
      StreamController<List<ProgramModel>>();

  void _fetchprograms() async {
    await getProgramCourse(_programStream);
  }

  @override
  void initState() {
    super.initState();
    _fetchprograms();
  }

  @override
  void dispose() {
    _programStream.close();
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
              indexPagesHeader("Program Courses"),
              Expanded(
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        addNewButton(context, _fetchprograms),
                        Expanded(
                          child: StreamBuilder<List<ProgramModel>>(
                            stream: _programStream.stream,
                            builder: (context, snapshot) {
                              List<ProgramModel> programs = snapshot.data ?? [];
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
                                    child: Text('No programs available.'));
                              } else {
                                return ListView.builder(
                                  itemCount: programs.length,
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
                                              Icons.book,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Center(
                                            child: Text(
                                              programs[index]
                                                  .courses
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          subtitle: Center(
                                            child: Text(
                                                "(${programs[index].abbr.toUpperCase()})"),
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
                                                  controller.abbr.text =
                                                      programs[index].abbr;
                                                  controller.course.text =
                                                      programs[index].courses;
                                                  showCustomDialog(
                                                      context,
                                                      ProgramPageEdit(
                                                          id: programs[index]
                                                              .id,
                                                          reload: () =>
                                                              _fetchprograms()));
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  const title =
                                                      'Delete Program';
                                                  const content =
                                                      'Are you sure you want to delete this program?';
                                                  confirmationDialog(
                                                      context,
                                                      title,
                                                      content,
                                                      () => deleteProgram(
                                                            context,
                                                            programs[index].id,
                                                          ).then((value) =>
                                                              _fetchprograms()));
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
