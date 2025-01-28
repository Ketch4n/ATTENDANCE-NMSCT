import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/view/program/model/program_model.dart';
import 'package:http/http.dart' as http;

Future<void> getProgramCourse(
    StreamController<List<ProgramModel>> stream) async {
  try {
    final response = await http.get(
      Uri.parse('${Server.host}users/establishment/program/get_program.php'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      List<ProgramModel> programs =
          jsonResponse.map((json) => ProgramModel.fromJson(json)).toList();

      stream.add(programs);
    } else {
      stream.add([]);
    }
  } catch (e) {
    stream.add([]);
  }
}
