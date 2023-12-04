// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/camera_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';

class CameraAuth extends StatefulWidget {
  const CameraAuth(
      {Key? key, required this.name, required this.refreshCallback})
      : super(key: key);
  final String name;
  final VoidCallback refreshCallback;

  @override
  State<CameraAuth> createState() => _CameraState();
}

class _CameraState extends State<CameraAuth> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  // late Stream<Position> _positionStream;
  StreamSubscription<Position>? _positionSubscription;

  bool _processingImage = false;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    Geolocator.checkPermission();
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

  final code = TextEditingController();
  final location = TextEditingController();

  final fulladdress = TextEditingController();

  void getCurrentPosition() async {
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
      getAddress(currentPosition.latitude, currentPosition.longitude);
      setState(() {
        location.text = lat + long;
      });
    }
  }

  void getAddress(double latitude, double longitude) async {
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

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    await _controller.initialize();
  }

  Future<void> _captureImage() async {
    if (_processingImage) {
      // Avoid capturing an image while processing another one
      return;
    }

    // Set the flag to true to indicate that an image is being processed
    setState(() {
      _processingImage = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // Initialize the face detector
      final faceDetector = GoogleMlKit.vision.faceDetector();

      final List<Face> faces = await faceDetector.processImage(inputImage);

      // Check if at least one face is detected
      if (faces.isNotEmpty) {
        const title = "Success";
        final message = Session.name;
        Navigator.of(context).pop(false);
        await cameraAlertDialog(context, title, message);

        widget.refreshCallback();
        // Upload the image to Firebase Storage with metadata
      } else {
        // No face detected
        const title = "Error";
        const message = "No Face Detected";
        await cameraAlertDialog(context, title, message);
      }
    } catch (e) {
      await showAlertDialog(context, 'Error capturing image', '$e');
    } finally {
      // Reset the flag when the image processing is complete
      setState(() {
        _processingImage = false;
      });

      // Navigator.of(context).pop(); // Close the processing dialog
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    fulladdress.dispose();
    getCurrentPosition;
    // _positionSubscription?.cancel(); // Cancel the location subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Auth'),
        centerTitle: true,
      ),
      floatingActionButton:
          fulladdress.text.isEmpty || fulladdress.text != Session.location
              ? FloatingActionButton(
                  onPressed: () {
                    print("current this: ${Session.location}");
                    getCurrentPosition();
                  },
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                  ),
                )
              : FloatingActionButton(
                  onPressed: _captureImage,
                  child: const Icon(
                    Icons.camera,
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !_processingImage) {
            if (fulladdress != "") {
              return Column(
                children: [
                  ListTile(
                      title: Text("Current Location:"),
                      subtitle: fulladdress.text != ""
                          ? Text(
                              fulladdress.text,
                              style: TextStyle(color: Colors.blue),
                            )
                          : Text(
                              "Offline",
                              style: TextStyle(color: Colors.red),
                            )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Status : "),
                      fulladdress.text != Session.location
                          ? Text(
                              "unmatched location",
                              style: TextStyle(color: Colors.red),
                            )
                          : Text(
                              "Location matched",
                              style: TextStyle(color: Colors.green),
                            ),
                    ],
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        CameraPreview(_controller),
                        Lottie.asset(
                          'assets/scanning.json',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("Turn on Location"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
