import 'dart:convert';

import 'package:attendance_nmsct/auth/google/functions/get_address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future fetchAndDisplayInfo(centerPosition) async {
  const url =
      'https://attendance-nmscst.online/db/map.php'; // Replace with your PHP script URL
  final params = {
    'location': '${centerPosition.latitude},${centerPosition.longitude}',
    'radius': '50',
    'type': 'point_of_interest',
  };

  try {
    final response = await http.post(Uri.parse(url), body: params);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final poi = data['results'][0];
        final poiName = poi['name'];
        final poiAddress = await getAddress(LatLng(
            poi['geometry']['location']['lat'],
            poi['geometry']['location']['lng']));

        return '$poiName $poiAddress';
      } else {
        final address = await getAddress(centerPosition);

        return address;
      }
    }
  } catch (e) {
    // print('Error fetching info: $e');

    return 'Error fetching info.';
  }
}
