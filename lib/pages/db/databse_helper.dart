import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/pages/models/user.model.dart';

class DatabaseHelper {
  static final String baseUrl = "${Server.host}auth/face_data.php";

  static final table = 'face_id';
  static final columnId = 'id';
  static final columnUser = 'user';
  static final columnPassword = 'password';
  static final columnModelData = 'model_data';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<int> insert(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'user': user.user,
        'password': user.password,
        'model_data': jsonEncode(user.modelData), // Convert List to JSON string
      },
    );

    if (response.statusCode == 200) {
      return 1; // Successful insertion
    } else {
      throw Exception('Failed to insert data');
    }
  }

  Future<List<User>> queryAllUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((u) => User.fromMap(u)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // ... (existing code)
}
