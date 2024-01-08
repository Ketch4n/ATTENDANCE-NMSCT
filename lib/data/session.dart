import 'package:google_maps_flutter/google_maps_flutter.dart';

class Session {
  static String id = "";
  static String role = "";
  static String name = "";
  static String email = "";
  static String longitude = "";
  static String latitude = "";
}

class Admin {
  static String id = "";
  static String name = "";
  static String email = "";
}

class User {
  static String location = "";
  static LatLng? coordinate;
  static double? latitude;
  static double? longitude;
}
// class User {
//   static double long = 0;
//   static double lat = 0;
// }
