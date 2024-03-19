import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FaceDone {
  static bool status = true;
}

// class UserRole {
//   static String role = 'Intern';
//   // static String role = 'Administrator';
//   // static String role = 'NMSCST';
// }
class UserRole extends ChangeNotifier {
  String role = kIsWeb ? "NMSCST" : "Intern";
  String get value => role;

  set value(String newValue) {
    role = newValue;
    // Step 2: Notify listeners when the value changes
    notifyListeners();
  }
}

class HoursRendered extends ChangeNotifier {
  String grandTotal = '';
  String get value => grandTotal;

  set value(String newValue) {
    grandTotal = newValue;
    notifyListeners();
  }
}
