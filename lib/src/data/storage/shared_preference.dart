import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserDataToPreferences(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', data['id']);
  prefs.setInt('userRole', data['role']);
  prefs.setString('userFName', data['fname']);
  prefs.setString('userLName', data['lname']);
  prefs.setString('userEmail', data['email']);

  Session.id = data['id'];
  Session.role = data['role'];
  Session.fname = data['fname'];
  Session.lname = data['lname'];
  Session.email = data['email'];
}
