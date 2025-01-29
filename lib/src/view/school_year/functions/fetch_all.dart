import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/view/school_year/model/school_year_model.dart';
import 'package:http/http.dart' as http;

Future getSchoolYear(StreamController<List<SchoolYearModel>> stream) async {
  try {
    final response = await http.get(
      Uri.parse(
          '${Server.host}users/establishment/school_year/view_all_school_year.php'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      List<SchoolYearModel> schoolYear =
          jsonResponse.map((json) => SchoolYearModel.fromJson(json)).toList();

      stream.add(schoolYear);
      return schoolYear;
    } else {
      stream.add([]);
      return [];
    }
  } catch (e) {
    stream.add([]);
    return [];
  }
}
