import 'package:attendance_nmsct/controller/Upload.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime now = DateTime.now();
final date = DateFormat('MM-dd-yyyy').format(now.toLocal());

Future accomplishmentReport(
    BuildContext context,
    ids,
    TextEditingController week,
    TextEditingController comment,
    VoidCallback refresh) async {
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
              leadingAndTrailingTextStyle:
                  const TextStyle(fontSize: 20, color: Colors.black),
              leading: const Text(
                "Accomplishment :",
              ),
              trailing: Text(DateFormat('MM/dd/yy').format(DateTime.now())),
            ),
            SizedBox(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: week,
                        decoration: InputDecoration(
                          hintText: 'Week #',
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
                        controller: comment,

                        maxLines:
                            null, // Set maxLines to null for multiline input
                        decoration: InputDecoration(
                          hintText: 'Write your accomplishment...',
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
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Close")),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.blue, // Text color of the button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Set the border radius
                                  ),
                                ),
                                onPressed: () async {
                                  String userComment = comment.text;
                                  String nweek = week.text;

                                  if (userComment.isEmpty || nweek.isEmpty) {
                                    Navigator.of(context).pop(true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Cannot add empty Accomplishment")));
                                  } else {
                                    Navigator.of(context).pop(true);
                                    await uploadAccomplishment(
                                        context, ids, nweek, userComment);

                                    comment.clear();
                                    refresh();
                                  }
                                },
                                child: const Text("Save")),
                          ],
                        ),
                      )

                      // SizedBox(
                      //     height: MediaQuery.of(context).viewInsets.bottom),
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
