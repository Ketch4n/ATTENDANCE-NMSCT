import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewMap extends StatelessWidget {
  ViewMap({
    super.key,
    required this.latitude1,
    required this.longitude1,
    required this.latitude2,
    required this.longitude2,
    required this.meter,
  });

  final double latitude1;
  final double longitude1;
  final double latitude2;
  final double longitude2;
  final double meter;

  late LatLng _center1;
  late LatLng _center2;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  Widget build(BuildContext context) {
    _center1 = LatLng(latitude1, longitude1);
    _center2 = LatLng(latitude2, longitude2);

    _markers.addAll([
      Marker(
        markerId: const MarkerId('Location1'),
        position: _center2,
        infoWindow:
            const InfoWindow(title: 'Establishment'), // Name for marker 1
      ),
      Marker(
        markerId: const MarkerId('Location2'),
        position: _center1,
        infoWindow:
            const InfoWindow(title: 'Check-in location'), // Name for marker 2
      ),
    ]);

    _circles.addAll([
      Circle(
        circleId: const CircleId('circle1'),
        center: _center2,
        radius: 0, // radius in meters
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
      ),
      Circle(
        circleId: const CircleId('circle2'),
        center: _center2,
        radius: meter, // radius in meters
        strokeWidth: 2,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
      ),
    ]);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _center1,
        zoom: 17.0,
      ),
      markers: _markers,
      circles: _circles,
      onMapCreated: (GoogleMapController controller) {
        // You can use the controller here if needed
      },
    );
  }
}
