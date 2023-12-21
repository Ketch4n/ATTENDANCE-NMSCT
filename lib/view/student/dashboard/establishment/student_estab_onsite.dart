import 'dart:async';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class StudentEstabOnsite extends StatefulWidget {
  const StudentEstabOnsite({super.key});

  @override
  State<StudentEstabOnsite> createState() => _StudentEstabOnsiteState();
}

class _StudentEstabOnsiteState extends State<StudentEstabOnsite> {
  final code = TextEditingController();
  final location = TextEditingController();
  final fulladdress = TextEditingController();
  // StreamSubscription<Position>? _positionSubscription;
  @override
  void initState() {
    super.initState();

    getCurrentPosition();
    // Listen to location changes
    // _positionSubscription = Geolocator.getPositionStream().listen(
    //   (Position position) {
    //     getCurrentPosition();
    //   },
    //   onError: (e) {
    //     print("Error getting location: $e");
    //   },
    // );
  }

  @override
  void dispose() {
    fulladdress.dispose();
    getCurrentPosition;
    // _positionSubscription?.cancel(); // Cancel the location subscription
    super.dispose();
  }

  void getCurrentPosition() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    double latitude = locationData.latitude!;
    double longitude = locationData.longitude!;

    print("Latitude : $latitude");
    print("Longitude : $longitude");

    getAddress(latitude, longitude);

    setState(() {
      location.text = '$latitude, $longitude';
    });
  }

  void getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0]; // Use the first placemark
        String address =
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              fulladdress.text == ""
                  ? Text("Unknown Location",
                      style: TextStyle(color: Colors.red))
                  : Text(fulladdress.text,
                      style: TextStyle(color: Colors.blue)),
              Text("Your Current Location")
            ]),
      ),
    );
  }
}
