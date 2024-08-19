import 'package:attendance_nmsct/auth/google/functions/fetch_info.dart';
import 'package:attendance_nmsct/auth/google/functions/get_address.dart';
import 'package:attendance_nmsct/auth/google/functions/location_permission.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey =
    'AIzaSyDMi2Vr5XERmRQOMISjj8V3Mk21T7z4LjU'; // Replace with your Google API Key

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
  static String default_info = "Click the icon or Drag the screen";
  String _address = default_info;

  final _places = places.GoogleMapsPlaces(apiKey: kGoogleApiKey);

  @override
  void initState() {
    super.initState();
    locateStart();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void locateStart() async {
    LatLng positions = await locateUser();
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

  void _getinfo() async {
    String address = await fetchAndDisplayInfo(_centerPosition);
    setState(() {
      _address = address;
    });
  }

  void _updateAddress() async {
    String address = await getAddress(_centerPosition);
    setState(() {
      _address = address;
    });
  }

  Future<void> _searchAndNavigate() async {
    try {
      Prediction? prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay,
        language: "en",
        components: [Component(Component.country, "ph")],
      );

      if (prediction != null && prediction.placeId != null) {
        final placesDetails =
            await _places.getDetailsByPlaceId(prediction.placeId!);

        if (placesDetails.result.geometry?.location != null) {
          final location = placesDetails.result.geometry!.location;
          final latLng = LatLng(location.lat, location.lng);

          setState(() {
            _centerPosition = latLng;
            _updateMap(); // Ensure _updateMap() is defined and handles the map update
          });
        } else {
          print("Error: No location data found.");
        }
      } else {
        print("Error: No prediction or place ID found.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchAndNavigate,
          ),
        ],
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
            onCameraIdle: _getinfo,
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 150,
            right: 150,
            child: FloatingActionButton(
              onPressed: locateStart,
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
                  UserSession.location =
                      _address == default_info ? "" : _address;
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
