import 'dart:async';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/dashboard/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:attendance_nmsct/src/view/student/calculate_distance.dart';

class DashboardProvider with ChangeNotifier {
  final TextEditingController _schoolYearController = TextEditingController();
  static String? _selectedYearRange = '2024-2025';

  String count = "";
  String count_estab = "";
  String count_courses = "";
  String absent = "";
  String late = "";
  double outside = 0;
  String announcement = "";
  List<String> outsideIds = [];
  final String defaultYear = "2024-2025";
  List<String> sy = [];

  DashboardProvider() {
    fetchSY();
    fetchInterns();
    dtr();
  }

  TextEditingController get schoolYearController => _schoolYearController;
  String? get selectedYearRange => _selectedYearRange;
  List<String> get schoolYears => sy;

  Future<void> fetchSY() async {
    try {
      sy = await DashboardService.fetchSY();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchInterns() async {
    try {
      final responseData = await DashboardService.fetchInterns(
        _schoolYearController.text.isEmpty
            ? defaultYear
            : _schoolYearController.text,
      );
      count = responseData['users'] ?? '0';
      count_estab = responseData['estab'] ?? '0';
      count_courses = responseData['courses'] ?? '0';
      absent = responseData['absent'] ?? '0';
      late = responseData['late'] ?? '0';
      announcement = responseData['announcement'] ?? '0';
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> dtr() async {
    try {
      outsideIds = [];
      outside = 0;

      final data = await DashboardService.fetchDtr(
        _schoolYearController.text.isEmpty
            ? defaultYear
            : _schoolYearController.text,
      );

      if (data.isEmpty) {
        outside = 0;
        outsideIds = [];
        print("No data returned for the specified year.");
        return;
      }

      final totalOutside = data.where((dtrItem) {
        double meterValue = double.parse(dtrItem.radius ?? '0');
        double estabLat = double.parse(dtrItem.latitude ?? '0');
        double estabLong = double.parse(dtrItem.longitude ?? '0');

        List<double> distances = [
          calculateDistance(double.parse(dtrItem.in_am_lat ?? '0'),
              double.parse(dtrItem.in_am_long ?? '0'), estabLat, estabLong),
          calculateDistance(double.parse(dtrItem.out_am_lat ?? '0'),
              double.parse(dtrItem.out_am_long ?? '0'), estabLat, estabLong),
          calculateDistance(double.parse(dtrItem.in_pm_lat ?? '0'),
              double.parse(dtrItem.in_pm_long ?? '0'), estabLat, estabLong),
          calculateDistance(double.parse(dtrItem.out_pm_lat ?? '0'),
              double.parse(dtrItem.out_pm_long ?? '0'), estabLat, estabLong),
        ];

        if (distances.any((distance) => distance > meterValue)) {
          outsideIds.add(dtrItem.id.toString());
          return true;
        }
        return false;
      }).length;

      outside = totalOutside.toDouble();
      print("Total Outside IDs: $outsideIds");
      notifyListeners();
    } catch (e) {
      print(e);
      outsideIds = [];
      outside = 0;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    fetchSY();
    fetchInterns();
    dtr();
  }

  void setSelectedYearRange(String? newValue) {
    _selectedYearRange = newValue;
    _schoolYearController.text = newValue ?? '';
    refresh();
  }
}
