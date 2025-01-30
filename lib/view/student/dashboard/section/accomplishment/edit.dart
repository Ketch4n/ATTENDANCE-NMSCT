import 'package:attendance_nmsct/controller/Upload.dart';
import 'package:attendance_nmsct/model/AccomplishmentModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future accomplishmentReportEdit(
    BuildContext context,
    ids,
    AccomplishmentModel record,
    TextEditingController week,
    TextEditingController comment,
    TextEditingController hte,
    TextEditingController area,
    TextEditingController sv,
    VoidCallback refresh) async {
  // Set initial values for the controllers
  final TextEditingController weekController =
      TextEditingController(text: record.week);
  final TextEditingController commentController =
      TextEditingController(text: record.comment.replaceAll('<br />', ''));

  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    barrierColor: Colors.black87.withOpacity(0.5),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7, // Half of the screen height
      maxChildSize: 0.8, // Almost cover the screen height
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const SizedBox(
              width: 50,
              child: Divider(
                color: Colors.black26,
                thickness: 4,
              ),
            ),
            ListTile(
                leading: const Text("Accomplishment:"),
                trailing: Text(record.date)),
            SizedBox(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: weekController,
                        decoration: InputDecoration(
                          hintText: 'Week #',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: hte,
                        decoration: InputDecoration(
                          hintText: 'HTE name',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                20.0), // Set the border radius
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                8.0), // Set the border radius
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: area,
                        decoration: InputDecoration(
                          hintText: 'Assigned Area',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                20.0), // Set the border radius
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                8.0), // Set the border radius
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: sv,
                        decoration: InputDecoration(
                          hintText: 'Super Visor',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                20.0), // Set the border radius
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue), // Set the color you want
                            borderRadius: BorderRadius.circular(
                                8.0), // Set the border radius
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: commentController,
                        maxLines: null, // For multiline input
                        decoration: InputDecoration(
                          hintText: 'Write your accomplishment...',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text("Close"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                String userComment = commentController.text;
                                String nweek = weekController.text;
                                String nhte = hte.text;
                                String narea = area.text;
                                String nsv = sv.text;

                                if (userComment.isEmpty || nweek.isEmpty) {
                                  Navigator.of(context).pop(true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Cannot add empty Accomplishment")));
                                } else {
                                  Navigator.of(context).pop(true);
                                  await uploadAccomplishment(
                                      context,
                                      record.section_id,
                                      nweek,
                                      nhte,
                                      narea,
                                      nsv,
                                      userComment,
                                      record.id);
                                  commentController.clear();
                                  refresh();
                                }
                              },
                              child: const Text("Save"),
                            ),
                          ],
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

int getWeekNumber(DateTime date) {
  return ((date.day - 1) / 7).floor() +
      1; // A simple calculation for the week number
}
