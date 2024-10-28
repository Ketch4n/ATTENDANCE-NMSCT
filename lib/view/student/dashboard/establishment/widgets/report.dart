import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> showReport(BuildContext context, String report, String InAM,
    String InPM, String? schedAM, String? schedPM) async {
  // Check if the time is before or at 8:00 AM

  return showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    barrierColor: Colors.black87.withOpacity(0.5),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.32,
      maxChildSize: 0.5,
      minChildSize: 0.32,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          height: 200,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                    leading: Text(
                      "Total Hours rendered :",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    trailing: Text(
                      report,
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Time In AM:",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    trailing: Text(
                      schedAM == null
                          ? "NOT SET"
                          : InAM.compareTo(schedAM) <= 0
                              ? "On Time"
                              : "Late",
                      style: TextStyle(
                          color: schedAM == null
                              ? Colors.blue
                              : InAM.compareTo(schedAM) <= 0
                                  ? Colors.green
                                  : Colors.red,
                          fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Time In PM:",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    trailing: Text(
                      schedPM == null
                          ? "NOT SET"
                          : InPM.compareTo(schedPM) <= 0 &&
                                  InPM.compareTo('00:00:00') != 0
                              ? "On Time"
                              : InPM.compareTo('00:00:00') == 0
                                  ? "Pending"
                                  : "Late",
                      style: TextStyle(
                          color: schedPM == null
                              ? Colors.blue
                              : InPM.compareTo(schedPM) <= 0 &&
                                      InPM.compareTo('00:00:00') != 0
                                  ? Colors.green
                                  : InPM.compareTo('00:00:00') == 0
                                      ? Colors.blue
                                      : Colors.red,
                          fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
