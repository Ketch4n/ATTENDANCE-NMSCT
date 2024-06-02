import 'package:attendance_nmsct/data/session.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late LatLng _centerPosition;
  String _address = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _centerPosition = LatLng(10.339696878741954,
        123.90249833464621); // Initial center position (San Francisco)
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<String> _getAddress(LatLng position) async {
    final apiKey = 'AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final addressComponents = data['results'][1]['address_components'];
          print(addressComponents);
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
            } else if (types.contains('subAdministrativeArea')) {
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

  Future<String> getAddressOld(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark address = placemarks[2];
        String addressStr = "";
        print(address);

        if (address.name != null &&
            !address.name!.toLowerCase().contains('unnamed') &&
            address.name != address.locality) {
          addressStr += "${address.name} ";
        }

        addressStr +=
            "${address.subLocality ?? ''} ${address.locality ?? ''}, ${address.subAdministrativeArea ?? ''}";

        return addressStr;
      }
    } catch (e) {
      print('Error fetching address using old method: $e');
    }
    return "Address not found";
  }

  void _updateAddress() async {
    String address = await getAddressOld(_centerPosition);
    setState(() {
      _address = address;
    });
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

    Position position = await Geolocator.getCurrentPosition();
    _centerPosition = LatLng(position.latitude, position.longitude);

    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_centerPosition, 18));
    _updateAddress();

    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId('current-location'),
        position: _centerPosition,
      ),
    );
    setState(() {});
  }

  Future<void> _fetchAndDisplayInfo() async {
    final apiKey = 'AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_centerPosition.latitude},${_centerPosition.longitude}&radius=50&type=point_of_interest&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
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
          final address = await getAddressOld(_centerPosition);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
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
            onCameraIdle:
                _fetchAndDisplayInfo, // Fetch info when camera stops moving
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 150,
            right: 150,
            child: FloatingActionButton(
              onPressed: _locateUser,
              child: Icon(Icons.my_location),
            ),
          ),
          Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),
          Positioned(
            // top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.yellow,
              child: Text(
                _address,
                style: TextStyle(fontSize: 16, color: Colors.black),
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
