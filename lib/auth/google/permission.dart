import 'package:geolocator/geolocator.dart';

Future determineUserCurrentPosition(purpose) async {
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
      desiredAccuracy: purpose == "pin"
          ? LocationAccuracy.best
          : LocationAccuracy.bestForNavigation);
}
