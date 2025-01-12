import 'package:flutter/foundation.dart';

class UserRole extends ChangeNotifier {
  int role = 1;
  int get value => role;

  set value(int newValue) {
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
