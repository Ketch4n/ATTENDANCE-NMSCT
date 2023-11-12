import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isKeyboard = false;
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
            initialChildSize:
                isKeyboard ? 0.8 : 0.5, // Half of the screen height
            minChildSize:
                isKeyboard ? 1 / 2 : 1 / 3, // 1/3 of the screen height
            maxChildSize:
                isKeyboard ? 0.9 : 0.5, // Almost cover the screen height
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
                              DateFormat('MM/dd/yy').format(DateTime.now())),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              controller: commentController,
                              onTap: () {
                                isKeyboard = true;
                              },
                              maxLines:
                                  null, // Set maxLines to null for multiline input
                              decoration: InputDecoration(
                                hintText: 'Write your comment...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                        // SizedBox(
                        //     height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
}
