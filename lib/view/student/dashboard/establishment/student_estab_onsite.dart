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
  final longi = TextEditingController();
  final lati = TextEditingController();
  // StreamSubscription<Position>? _positionSubscription;
  @override
  void initState() {
    super.initState();

    getCurrentPosition();
  }

  @override
  void dispose() {
    code.dispose();
    location.dispose();
    fulladdress.dispose();
    longi.dispose();
    lati.dispose();
    super.dispose();
  }

  void getCurrentPosition() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    double latitude = locationData.latitude!;
    double longitude = locationData.longitude!;

    getAddress(locationData.latitude!, locationData.longitude!);

    setState(() {
      longi.text = longitude.toString();
      lati.text = latitude.toString();
      location.text = latitude.toString() + longitude.toString();
    });
  }

  void getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      print(placemarks);
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
