import 'dart:async';
import 'dart:io';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/functions/generate.dart';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';

class Camera extends StatefulWidget {
  const Camera({super.key, required this.name, required this.refresh});
  final String name;
  final VoidCallback refresh;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  StreamSubscription<loc.LocationData>? _positionSubscription;

  final location = TextEditingController();
  final fulladdress = TextEditingController();
  int userId = 0;
  bool _processingImage = false;
  File? _capturedImage;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _positionSubscription = loc.Location().onLocationChanged.listen(
      (loc.LocationData locationData) {
        getCurrentPosition();
      },
      onError: (e) {
        print("Error getting location: $e");
      },
    );
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
        Placemark placemark = placemarks[2];
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

  @override
  void dispose() {
    _controller.dispose();
    _initializeCamera;
    fulladdress.text;
    _positionSubscription?.cancel();
    super.dispose();
  }

  // Future uploadImageToFirebaseStorage(File imageFile) async {
  //   DateTime now = DateTime.now();
  //   final date = DateFormat('yyyy-MM-dd').format(now.toLocal());
  //   final storage = FirebaseStorage.instance;
  //   final section = widget.name;
  //   final folderName =
  //       'face_data/$section/${Session.email}'; // Specify your folder name
  //   final randomFilename = getRandomString(10);

  //   final Reference storageRef = storage.ref().child(
  //       '$folderName/$date/$randomFilename.jpg'); // Use folder name in the path

  //   final metadata = SettableMetadata(
  //     customMetadata: {
  //       'Time taken': DateFormat('hh:mm a').format(now.toLocal()),
  //       'Date taken': DateFormat('yyyy-MM-dd').format(now.toLocal()),
  //       'Name': Session.name,
  //       'Location': fulladdress.text,
  //     },
  //   );

  //   try {
  //     final uploadTask = storageRef.putFile(
  //       imageFile,
  //       SettableMetadata(contentType: 'image/jpeg'),
  //     );

  //     await uploadTask;
  //     await storageRef.updateMetadata(metadata);
  //     const title = "Success";
  //     final message = "Face ID : ${Session.name}";
  //     Navigator.of(context).pop();
  //     await cameraAlertDialog(context, title, message);
  //     widget.refresh();
  //   } catch (e) {
  //     print('Error uploading image to Firebase: $e');
  //   }
  // }

  void _uploadImage(File imageFile) async {
    setState(() {
      _uploading = true;
    });

    DateTime now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now.toLocal());
    final storage = FirebaseStorage.instance;
    final section = widget.name;
    final folderName =
        'face_data/$section/${Session.email}'; // Specify your folder name
    final randomFilename = getRandomString(10);

    final Reference storageRef = storage.ref().child(
        '$folderName/$date/$randomFilename.jpg'); // Use folder name in the path

    final metadata = SettableMetadata(
      customMetadata: {
        'Time taken': DateFormat('hh:mm a').format(now.toLocal()),
        'Date taken': DateFormat('yyyy-MM-dd').format(now.toLocal()),
        'Name': Session.fname + Session.lname,
        'Location': fulladdress.text,
      },
    );

    try {
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask;
      await storageRef.updateMetadata(metadata);
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  // Future _captureImage() async {
  //   if (_processingImage) {
  //     return;
  //   }

  //   setState(() {
  //     _processingImage = true;
  //   });

  //   try {
  //     await _initializeControllerFuture;
  //     final image = await _controller.takePicture();
  //     final inputImage = InputImage.fromFilePath(image.path);

  //     final faceDetector = GoogleMlKit.vision.faceDetector();

  //     final List<Face> faces = await faceDetector.processImage(inputImage);

  //     if (faces.isNotEmpty) {
  //       setState(() {
  //         _capturedImage = File(image.path);
  //         _uploading = false;
  //       });
  //     } else {
  //       const title = "Error";
  //       const message = "No Face Detected";
  //       cameraAlertDialog(context, title, message);
  //       setState(() {
  //         _processingImage = true;
  //         _uploading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error capturing image: $e');
  //   } finally {
  //     setState(() {
  //       _processingImage = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !_processingImage) {
                return CameraPreview(_controller);
              } else if (_capturedImage != null) {
                return Column(
                  children: [
                    ListTile(
                        title: const Text("Location"),
                        subtitle: fulladdress.text == ""
                            ? const Text("Scanning...")
                            : Text(fulladdress.text)),
                    Image.file(_capturedImage!),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          // _buildCapturedImagePreview(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _processingImage = false;
          _uploadImage(_capturedImage!);
          const title = "Success";
          const message = "Uploaded successfully";
          // await cameraAlertDialog(context, title, message);
          Navigator.of(context).pop();

          widget.refresh();
        },
        child: _capturedImage == null
            ? const Icon(Icons.camera)
            : const Icon(Icons.upload),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
