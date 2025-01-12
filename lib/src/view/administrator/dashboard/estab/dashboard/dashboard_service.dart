import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/model/EstabTodayModel.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';

class DashboardService {
  static Future<List<String>> fetchSY() async {
    try {
      final response = await http
          .get(Uri.parse('${Server.host}users/establishment/school_year.php'));

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        return List<String>.from(responseData);
      } else {
        throw Exception('Failed to load school years: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching school years: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchInterns(String year) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/count.php'),
        body: {"years": year},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching interns: $e');
    }
  }

  static Future<List<EstabTodayModel>> fetchDtr(String year) async {
    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/student/outside.php'),
        body: {"year": year},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((dtrData) => EstabTodayModel.fromJson(dtrData))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching DTR: $e');
    }
  }
}
