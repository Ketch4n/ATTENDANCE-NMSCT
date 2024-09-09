import 'package:flutter/foundation.dart';

class UserRole extends ChangeNotifier {
  String role = kIsWeb ? "NMSCST" : "Intern";
  String get value => role;

  set value(String newValue) {
    role = newValue;

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
