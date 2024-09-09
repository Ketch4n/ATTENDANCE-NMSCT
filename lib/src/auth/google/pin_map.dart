// ignore_for_file: avoid_print

import 'dart:async';

import 'package:attendance_nmsct/src/auth/google/permission.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';

class PinMap extends StatefulWidget {
  const PinMap({super.key});

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
                const SizedBox(width: 8.0),
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
      // circles: {
      //   Circle(
      //       circleId: CircleId("1"),
      //       center: _defaultLatLng,
      //       radius: 10,
      //       strokeWidth: 1,
      //       fillColor: Colors.blue.withOpacity(0.2))
      // },
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

  Future<void> _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark address = placemarks.first;

      // Construct the address string using desired fields from the first placemark
      String addressStr = "";

      // Check if the thoroughfare is an unnamed road before including it in the address
      if (address.thoroughfare != null &&
          !address.thoroughfare!.toLowerCase().contains('unnamed')) {
        addressStr += "${address.thoroughfare} ";
      }

      // Include other address components
      addressStr +=
          "${address.subThoroughfare ?? ''} ${address.subLocality ?? ''} ${address.locality ?? ''}, ${address.subAdministrativeArea ?? ''}";

      // Update the state with the constructed address string
      setState(() {
        _draggedAddress = addressStr
            .trim(); // Trim to remove any leading or trailing whitespace
      });
    } else {
      setState(() {
        _draggedAddress = "Address not found";
      });
    }
  }

  Future _gotoUserCurrentPosition() async {
    const purpose = "pin";
    Position currentPosition = await determineUserCurrentPosition(purpose);
    _gotoSpecificPosition(
        LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 17.5)));
    await _getAddress(position);
  }

  void _toggleMapStyle() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }
}
