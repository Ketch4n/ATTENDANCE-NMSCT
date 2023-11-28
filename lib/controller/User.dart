import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future fetchUser(userStreamController) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');
  if (userRole == 'Student') {
    final response = await http.post(
      Uri.parse('${Server.host}auth/user.php'),
      body: {'id': userId},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = UserModel.fromJson(data);
      final userEstabLocation = user.location;
      prefs.setString('userEstabLocation', userEstabLocation);

      Session.location = userEstabLocation;
      // Add the user data to the stream
      userStreamController.add(user);
    } else {
      throw Exception('Failed to load data');
    }
  } else {
    final response = await http.post(
      Uri.parse('${Server.host}users/establishment/user.php'),
      body: {'id': userId},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final user = UserModel.fromJson(data);

      // Add the user data to the stream
      userStreamController.add(user);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

Future<void> fetchClassRoom() async {
  final response =
      await http.get(Uri.parse('${Server.host}users/student/class_room.php'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
  } else {
    print('Failed to fetch data: ${response.reasonPhrase}');
  }
}

// Stream<List<StreamUserModel>> streamUser() async* {
//   while (true) {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');
//     final response = await http.post(
//       Uri.parse('${Server.host}auth/user.php'),
//       body: {'id': userId},
//     );
//     // print('API Response: ${response.body}');
//     if (response.statusCode == 200) {
//       List<dynamic> jsonList = json.decode(response.body);
//       yield jsonList.map((json) => StreamUserModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load data');
//     }

//     await Future.delayed(
//         const Duration(seconds: 2)); // Adjust the refresh rate as needed
//   }
// }
