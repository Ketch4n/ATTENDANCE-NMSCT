import 'package:attendance_nmsct/data/session.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  late LatLng _centerPosition =
      const LatLng(10.339696878741954, 123.90249833464621);
  String _address = 'Drag the screen';

  @override
  void initState() {
    super.initState();
    _locateUser(); // Optionally fetch user's location on start
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<String> _getAddress(LatLng position) async {
    final url =
        'https://attendance-nmscst.online/db/address.php'; // Replace with your PHP script URL
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
      print('Error fetching address: $e');
    }
    return 'Unknown Location';
  }

  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position positions = await Geolocator.getCurrentPosition();
    setState(() {
      _centerPosition = LatLng(positions.latitude, positions.longitude);
      _updateMap();
    });
  }

  void _updateMap() {
    if (mapController != null) {
      mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_centerPosition, 18));
      _updateAddress();
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current-location'),
          position: _centerPosition,
        ),
      );
    }
  }

  Future<void> _fetchAndDisplayInfo() async {
    if (_centerPosition == null) return;

    final url =
        'https://attendance-nmscst.online/db/map.php'; // Replace with your PHP script URL
    final params = {
      'location': '${_centerPosition.latitude},${_centerPosition.longitude}',
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
          final poiAddress = await _getAddress(LatLng(
              poi['geometry']['location']['lat'],
              poi['geometry']['location']['lng']));

          setState(() {
            _address = '$poiName $poiAddress';
          });
        } else {
          final address = await _getAddress(_centerPosition);
          setState(() {
            _address = address;
          });
        }
      }
    } catch (e) {
      print('Error fetching info: $e');
      setState(() {
        _address = 'Error fetching info.';
      });
    }
  }

  void _updateAddress() async {
    String address = await _getAddress(_centerPosition);
    setState(() {
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _centerPosition,
              zoom: 18,
            ),
            onCameraMove: (position) {
              _centerPosition = position.target;
            },
            onCameraIdle: _fetchAndDisplayInfo,
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 150,
            right: 150,
            child: FloatingActionButton(
              onPressed: _locateUser,
              child: const Icon(Icons.my_location),
            ),
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.yellow,
              child: Text(
                _address,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 100,
            right: 100,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  UserSession.location = _address;
                  UserSession.coordinate = _centerPosition;
                  UserSession.latitude = _centerPosition.latitude;
                  UserSession.longitude = _centerPosition.longitude;

                  Navigator.of(context).pop(_address);
                });
              },
              child: const Text('Save'),
            ),
          )
        ],
      ),
    );
  }
}
