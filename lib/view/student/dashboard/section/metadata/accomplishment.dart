import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future accomplishmentReport(
    BuildContext context, TextEditingController commentController) async {
  return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      barrierColor: Colors.black87.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            // maxChildSize: 0.5,
            minChildSize: 0.32,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          leadingAndTrailingTextStyle: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          leading: const Text(
                            "Accomplishment :",
                          ),
                          trailing: Text(
                              DateFormat('mm/dd/yy').format(DateTime.now())),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            controller: commentController,
                            maxLines:
                                null, // Set maxLines to null for multiline input
                            decoration: InputDecoration(
                              hintText: 'Write your comment...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
}
