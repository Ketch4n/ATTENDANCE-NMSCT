import 'dart:async';
import 'dart:io';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/widgets/camera_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key, required this.name, required this.refresh})
      : super(key: key);
  final String name;
  final VoidCallback refresh;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  StreamSubscription<Position>? _positionSubscription;

  int userId = 0;
  bool _processingImage = false;
  File? _capturedImage;
  bool _option = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _positionSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        getCurrentPosition();
      },
      onError: (e) {
        print("Error getting location: $e");
      },
    );
  }

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

  @override
  void dispose() {
    _controller.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> uploadImageToFirebaseStorage(File imageFile) async {
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
        'Name': Session.name,
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
      const title = "Success";
      final message = "Face ID : ${Session.name}";

      await cameraAlertDialog(context, title, message);
      widget.refresh();
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
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
        'Name': Session.name,
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
      const title = "Success";
      final message = "Face ID : ${Session.name}";
      await cameraAlertDialog(context, title, message);
      Navigator.of(context).pop();
      widget.refresh();
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_processingImage) {
      return;
    }

    setState(() {
      _processingImage = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      final faceDetector = GoogleMlKit.vision.faceDetector();

      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() {
          _capturedImage = File(image.path);
          _option = true;
        });
      } else {
        const title = "Error";
        const message = "No Face Detected";
        await cameraAlertDialog(context, title, message);
        setState(() {
          _processingImage = false;
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      // setState(() {
      //   _processingImage = false;
      // });

      // Navigator.of(context).pop();
    }
  }

  Widget _buildCapturedImagePreview() {
    if (_capturedImage != null) {
      return Column(
        children: [
          ListTile(
              leading: Text("Location"),
              trailing: fulladdress.text == ""
                  ? Text("Scanning...")
                  : Text(fulladdress.text)),
          Image.file(_capturedImage!),
          TextButton(
            child: Text('Upload Now'),
            onPressed: () {
              _processingImage = false;

              _uploadImage(_capturedImage!);
            },
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !_processingImage) {
                return CameraPreview(_controller);
              } else {
                return SizedBox();
              }
            },
          ),
          _buildCapturedImagePreview(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
