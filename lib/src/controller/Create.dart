// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future CreateSectEstab(BuildContext context, String cont, String loc,
    double lng, double lat, String hours, String radius) async {
  // final prefs = await SharedPreferences.getInstance();
  final intHours = int.tryParse(hours) ?? 0; // Convert hours to integer
  // Calculate hours, minutes, and seconds
  final hoursPart = intHours.toString().padLeft(3, '0');
  const minutesPart = '00';
  const secondsPart = '00';

  // Construct the formatted duration string
  final durationH = '$hoursPart:$minutesPart:$secondsPart';
  // final userId = prefs.getString('userId');
  // final userRole = prefs.getString('userRole');
  Map<String, String> headers = {'Content-Type': 'application/json'};

  try {
    String apiUrl = '${Server.host}users/establishment/create.php';
    Object finalLocation = kIsWeb ? lat + lng : loc;
    String jsonData =
        '{ "establishment_name": "$cont",  "location":"$finalLocation","longitude":"$lng","latitude":"$lat", "hours_required":"$durationH", "radius":"$radius"}';
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);
    final jsonResponse = json.decode(response.body);
    final message = jsonResponse['message'];
    final status = jsonResponse['status'];

    if (response.statusCode == 200) {
      await showAlertDialog(context, status, message);
      // await showAlertDialog(context, status, message);
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => const Login()));

      Navigator.of(context).pop();

      // Handle success message as needed
    } else if (response.statusCode == 400) {
      // code already taken
      await showAlertDialog(context, status, message);
      // Handle code taken message as needed
    } else {
      // Handle other status codes (e.g., 500, 405) as needed
    }
  } catch (e) {
    print('Error: $e');
  }
}

String _formatHours(String hours) {
  // Assuming the input hours is a string representing the total number of hours
  int totalHours = int.parse(hours);

  // Calculate hours, minutes, and seconds
  int hoursInt = totalHours ~/ 3600;
  int minutesInt = (totalHours % 3600) ~/ 60;
  int secondsInt = totalHours % 60;

  // Return formatted string
  return '$hoursInt:${minutesInt.toString().padLeft(2, '0')}:${secondsInt.toString().padLeft(2, '0')}';
}
