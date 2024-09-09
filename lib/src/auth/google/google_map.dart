// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// const LatLng currentLocation = LatLng(8.4672512, 123.8007808);

// class GoogleMapPage extends StatefulWidget {
//   const GoogleMapPage({super.key});

//   @override
//   State<GoogleMapPage> createState() => _GoogleMapPageState();
// }

// class _GoogleMapPageState extends State<GoogleMapPage> {
//   Set<Marker> _markers = Set(); // Set to manage markers
//   LatLng _tappedLocation =
//       LatLng(0.0, 0.0); // Variable to store tapped location

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         initialCameraPosition:
//             CameraPosition(target: currentLocation, zoom: 10),
//         markers: _markers,
//         onTap: (LatLng location) {
//           // Handle tap on the map
//           setState(() {
//             _tappedLocation = location;
//             _markers.clear(); // Clear existing markers
//             _markers.add(
//               Marker(
//                 markerId: MarkerId(_tappedLocation.toString()),
//                 position: _tappedLocation,
//                 infoWindow: InfoWindow(
//                   title: 'Tapped Location',
//                   snippet:
//                       'Lat: ${_tappedLocation.latitude}, Lng: ${_tappedLocation.longitude}',
//                 ),
//               ),
//             );
//           });

//           // You can now use the _tappedLocation variable to access the latitude and longitude
//           print(
//               'Tapped Location: ${_tappedLocation.latitude}, ${_tappedLocation.longitude}');
//         },
//       ),
//     );
//   }
// }
