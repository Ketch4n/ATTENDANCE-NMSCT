import 'package:google_maps_flutter/google_maps_flutter.dart';

class Session {
  static String id = "";
  static String role = "";
  static String fname = "";
  static String lname = "";
  static String email = "";
  static double? longitude;
  static double? latitude;
  static double? radius;

  static String password = "";
  static String hours_required = "";
}

class Admin {
  static String id = "";
  static String name = "";
  static String email = "";
  static String estab_id = "";
}

class UserSession {
  static String location = "";
  static LatLng? coordinate;
  static double? latitude;
  static double? longitude;
}

// class User {
//   static double long = 0;
//   static double lat = 0;
// }
class UserProfileInfo {
  static String uid = "";
  static String bday = "";
  static String address = "";
}
