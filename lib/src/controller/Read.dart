import 'dart:convert';

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/model/RoomModel.dart';
import 'package:http/http.dart' as http;

Future<void> fetchClassmates(classmateStreamController, id) async {
  final response = await http.post(
    Uri.parse('${Server.host}users/student/room.php'),
    body: {'establishment_id': id},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<RoomModel> classmates =
        data.map((classmateData) => RoomModel.fromJson(classmateData)).toList();

    // Admin.id = classmates[0].creator_id;
    // Admin.name = classmates[0].creator_fname;
    // Admin.email = classmates[0].creator_email;

    // Add the list of classmates to the stream
    classmateStreamController.add(classmates);
  } else {
    throw Exception('Failed to load data');
  }
}
