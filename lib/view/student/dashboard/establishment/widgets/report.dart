import 'package:flutter/material.dart';

Future showReport(BuildContext context) async {
  return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      barrierColor: Colors.black87.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.32,
            maxChildSize: 0.5,
            minChildSize: 0.32,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: const SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Divider(
                            color: Colors.black26,
                            thickness: 4,
                          ),
                        ),
                        ListTile(
                          leadingAndTrailingTextStyle: TextStyle(fontSize: 20),
                          leading: Text(
                            "Status :",
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            "Pending",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        ListTile(
                          leadingAndTrailingTextStyle: TextStyle(fontSize: 20),
                          leading: Text(
                            "Over-Time :",
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            "--/--",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        ListTile(
                          leadingAndTrailingTextStyle: TextStyle(fontSize: 20),
                          leading: Text(
                            "Total Hours rendered :",
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            "--/--",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
}
