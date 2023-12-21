// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/camera_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

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
  StreamSubscription<loc.LocationData>? _positionSubscription;

  bool _processingImage = false;
  bool _no = false;

  int userId = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    // Geolocator.checkPermission();
    // getCurrentPosition();
    estabLocation();
    // Listen to location changes
    _positionSubscription = loc.Location().onLocationChanged.listen(
      (loc.LocationData locationData) {
        getCurrentPosition();
      },
      onError: (e) {
        print("Error getting location: $e");
      },
    );
  }

  final code = TextEditingController();
  final location = TextEditingController();

  final fulladdress = TextEditingController();
  final estabAddressLocation = TextEditingController();

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
        Placemark placemark = placemarks[0];
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

  void estabLocation() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          Session.latitude as double, Session.longitude as double);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String estabAddress = "";
        estabAddress +=
            "${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}";
        print("Full Address: $estabAddress");
        setState(() {
          estabAddressLocation.text = estabAddress;
        });
      } else {
        print("No address found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future _initializeCamera() async {
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

  Future _captureImage() async {
    if (_processingImage) {
      // Avoid capturing an image while processing another one
      return;
    }

    // // Set the flag to true to indicate that an image is being processed
    // setState(() {
    //   _processingImage = true;
    // });

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
        final message = "Face Auth Detected";
        setState(() {
          _no = true;
        });
        Navigator.of(context).pop(false);
        await cameraAlertDialog(context, title, message);
        widget.refreshCallback();

        // Upload the image to Firebase Storage with metadata
      } else {
        // No face detected
        const title = "Error";
        const message = "No Face Detected";
        Navigator.of(context).pop(false);
        cameraAlertDialog(context, title, message);
      }
    } catch (e) {
      await showAlertDialog(context, 'Error capturing image', '$e');
    }
    // finally {
    //   // Reset the flag when the image processing is complete
    //   setState(() {
    //     _processingImage = false;
    //   });

    //   // Navigator.of(context).pop(); // Close the processing dialog
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    fulladdress.dispose();

    // getCurrentPosition;
    getAddress;
    estabLocation;
    _positionSubscription?.cancel(); // Cancel the location subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Auth'),
        centerTitle: true,
      ),
      // floatingActionButton: fulladdress.text.isEmpty
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           // print("current this: ${Session.location}");
      //           getCurrentPosition();
      //         },
      //         child: const Icon(
      //           Icons.location_pin,
      //           color: Colors.red,
      //         ),
      //       )
      //     : FloatingActionButton(
      //         onPressed: _captureImage,
      //         child: const Icon(
      //           Icons.camera,
      //         ),
      //       ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (fulladdress != "") {
              if (fulladdress.text != estabAddressLocation.text &&
                  _no == false) {
                // Location matched, automatically capture image
                _captureImage();
              }
              return Expanded(
                child: Column(
                  children: [
                    ListTile(
                        title: Text("Current Location:"),
                        subtitle: fulladdress.text != ""
                            ? Text(
                                fulladdress.text,
                                style: TextStyle(color: Colors.blue),
                              )
                            : Text(
                                "Scanning...",
                                style: TextStyle(color: Colors.blue),
                              )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Status : "),
                        fulladdress.text == estabAddressLocation.text
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
                ),
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
