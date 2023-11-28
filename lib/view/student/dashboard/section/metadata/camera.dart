// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/widgets/camera_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  int userId = 0;
  bool _processingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
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
        'Location': 'offline',
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
      // Navigator.of(context).pop(false);
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
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
        await uploadImageToFirebaseStorage(File(image.path));
      } else {
        // No face detected
        const title = "Error";
        const message = "No Face Detected";
        await cameraAlertDialog(context, title, message);
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      // Reset the flag when the image processing is complete
      setState(() {
        _processingImage = false;
      });

      Navigator.of(context).pop(); // Close the processing dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !_processingImage) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: CameraPreview(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
