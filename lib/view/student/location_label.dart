import 'package:attendance_nmsct/view/student/view_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LocationLabel extends StatelessWidget {
  LocationLabel({
    super.key,
    required this.distance,
    required this.meter,
    required this.latitude,
    required this.longitude,
    required this.estabLat,
    required this.estabLong,
  });
  double distance;
  double meter;
  double latitude;
  double longitude;
  double estabLat;
  double estabLong;
  double negative = -1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewMap(
              latitude1: latitude,
              longitude1: longitude,
              latitude2: estabLat,
              longitude2: estabLong,
              meter: meter))),
      child: Text(
        distance == negative
            ? ""
            : distance > meter
                ? "  / Outside range"
                : " / In-range",
        style: TextStyle(color: distance > meter ? Colors.orange : Colors.blue),
      ),
    );
  }
}
