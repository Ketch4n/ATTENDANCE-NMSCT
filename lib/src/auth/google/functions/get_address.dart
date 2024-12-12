import 'dart:convert';

import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<String> getAddress(LatLng position) async {
  var url = '${Server.host}db/address.php'; // Replace with your PHP script URL
  final params = {'latlng': '${position.latitude},${position.longitude}'};

  try {
    final response = await http.post(Uri.parse(url), body: params);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final addressComponents = data['results'][0]['address_components'];
        String street = '';
        String city = '';
        String sublocality = '';
        String subAdministrativeArea = '';
        for (var component in addressComponents) {
          final types = component['types'];
          if (types.contains('route')) {
            street = component['long_name'];
          } else if (types.contains('locality')) {
            city = component['long_name'];
          } else if (types.contains('sublocality')) {
            sublocality = component['long_name'];
          } else if (types.contains('administrative_area_level_2')) {
            subAdministrativeArea = component['long_name'];
          }
        }
        return '$street $sublocality $city $subAdministrativeArea';
      }
    }
  } catch (e) {
    // print('Error fetching address: $e');
  }
  return 'Unknown Location';
}
