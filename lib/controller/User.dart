import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/data/cache_hive.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<UserModel> _fetchUserFromApi(String userId, String userRole) async {
  final Uri uri = userRole == 'Intern'
      ? Uri.parse('${Server.host}auth/user.php')
      : Uri.parse('${Server.host}users/establishment/user.php');

  final response = await http.post(uri, body: {'id': userId});
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return UserModel.fromJson(data);
  } else {
    throw Exception('Failed to load data');
  }
}

Future<void> fetchUser(StreamController<UserModel> userStreamController) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final userRole = prefs.getString('userRole');

  if (userId == null || userRole == null) {
    throw Exception('User ID or Role not found in shared preferences');
  }

  // Attempt to get cached data
  var cachedData = ApiCache.getCachedData('user_$userId');
  if (cachedData != null) {
    final user = UserModel.fromJson(json.decode(cachedData));
    userStreamController.add(user);
  }

  // Fetch new data from the API
  final user = await _fetchUserFromApi(userId, userRole);

  // Update session values
  try {
    Session.longitude = double.parse(user.longitude.trim());
    Session.latitude = double.parse(user.latitude.trim());
    Session.radius = double.parse(user.radius.trim());
  } catch (e) {
    print("Error parsing longitude or latitude: $e");
  }
  Session.hours_required = user.hours_required;

  // Cache the new data
  await ApiCache.cacheData('user_$userId', json.encode(user.toJson()));

  // Add the new user data to the stream
  userStreamController.add(user);
}

// Periodically check for updates
void startUserUpdateTimer(StreamController<UserModel> userStreamController) {
  Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
    await fetchUser(userStreamController);
  });
}
