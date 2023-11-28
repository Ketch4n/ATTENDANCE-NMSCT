import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class StudentEstabOnsite extends StatefulWidget {
  const StudentEstabOnsite({super.key});

  @override
  State<StudentEstabOnsite> createState() => _StudentEstabOnsiteState();
}

class _StudentEstabOnsiteState extends State<StudentEstabOnsite> {
  final code = TextEditingController();
  final location = TextEditingController();
  final fulladdress = TextEditingController();
  StreamSubscription<Position>? _positionSubscription;
  @override
  void initState() {
    super.initState();

    Geolocator.checkPermission();

    // Listen to location changes
    _positionSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        getCurrentPosition();
      },
      onError: (e) {
        print("Error getting location: $e");
      },
    );
  }

  @override
  void dispose() {
    fulladdress.dispose();
    _positionSubscription?.cancel(); // Cancel the location subscription
    super.dispose();
  }

  Future<void> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permission Not given");
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true);
      print("Latitude : ${currentPosition.latitude}");
      print("Longitude : ${currentPosition.longitude}");
      String lat = currentPosition.latitude.toString();
      String long = currentPosition.longitude.toString();
      await getAddress(currentPosition.latitude, currentPosition.longitude);
      setState(() {
        location.text = lat + long;
      });
    }
  }

  Future<void> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      // print(placemarks);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[2];
        String address = "";

        address +=
            "${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}";
        print("Full Address: $address");

        setState(() {
          fulladdress.text = address;
        });
      } else {
        print("No address found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCurrentPosition();
        },
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: ListTile(
            title: fulladdress.text == ""
                ? Text("Unknown Location", style: TextStyle(color: Colors.red))
                : Text(fulladdress.text, style: TextStyle(color: Colors.blue)),
            subtitle: Text("Your Current Location")),
      ),
    );
  }
}
