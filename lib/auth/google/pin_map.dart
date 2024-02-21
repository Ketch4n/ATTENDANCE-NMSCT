// ignore_for_file: avoid_print

import 'dart:async';

import 'package:attendance_nmsct/data/session.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';

class PinMap extends StatefulWidget {
  const PinMap({Key? key}) : super(key: key);

  @override
  State<PinMap> createState() => _PinMapState();
}

class _PinMapState extends State<PinMap> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  late LatLng _defaultLatLng;
  late LatLng _draggedLatlng;

  String _draggedAddress = "";
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    _defaultLatLng = const LatLng(8.4672512, 123.8007808);
    _draggedLatlng = _defaultLatLng;
    _cameraPosition = CameraPosition(target: _defaultLatLng, zoom: 17.5);
    _gotoUserCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _getMap(),
        _getCustomPin(),
        _showDraggedAddress(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _gotoUserCurrentPosition,
                  child: const Icon(Icons.location_on),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _toggleMapStyle,
                  child: const Icon(Icons.map),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _showDraggedAddress() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _draggedAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                UserSession.location = _draggedAddress;
                UserSession.coordinate = _draggedLatlng;
                UserSession.latitude = _draggedLatlng.latitude;
                UserSession.longitude = _draggedLatlng.longitude;

                Navigator.of(context).pop(_draggedAddress);
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _getMap() {
    return GoogleMap(
      initialCameraPosition: _cameraPosition!,
      mapType: _currentMapType,
      onCameraIdle: () {
        _getAddress(_draggedLatlng);
      },
      onCameraMove: (cameraPosition) {
        _draggedLatlng = cameraPosition.target;
      },
      onMapCreated: (GoogleMapController controller) {
        if (!_googleMapController.isCompleted) {
          _googleMapController.complete(controller);
        }
      },
      circles: {
        Circle(
            circleId: CircleId("1"),
            center: _defaultLatLng,
            radius: 10,
            strokeWidth: 1,
            fillColor: Colors.blue.withOpacity(0.2))
      },
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: SizedBox(
        width: 150,
        child: Lottie.asset("assets/pin.json"),
      ),
    );
  }

  Widget _getMapStyleSwitchButton() {
    return Positioned(
      top: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        onPressed: _toggleMapStyle,
        child: const Icon(Icons.map),
      ),
    );
  }

  Future _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks.first; // Get the first placemark
    String addressStr =
        "${address.street}, ${address.locality}, ${address.country}";
    setState(() {
      _draggedAddress = addressStr;
    });

    // Calculate distance between dragged position and circle center
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _defaultLatLng.latitude,
      _defaultLatLng.longitude,
    );

    // Check if the distance is greater than circle radius (10 meters in this case)
    if (distance > 10) {
      // Notify the user that they are outside the circle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are outside the circle!'),
        ),
      );
    } else if (distance <= 10) {
      print("inside");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are '),
        ),
      );
    }
  }

  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    _gotoSpecificPosition(
        LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 17.5)));
    await _getAddress(position);
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      print("user don't enable location permission");
    }

    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        print("user denied location permission");
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      print("user denied permission forever");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  void _toggleMapStyle() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }
}
