import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key, required this.name}) : super(key: key);
  final String name;
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int userId = 0;

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
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    final storage = FirebaseStorage.instance;
    final section = widget.name;
    final folderName =
        'face_data/$section/$storedUserId'; // Specify your folder name
    DateTime now = DateTime.now();
    final time = DateFormat('yyyy-MM-dd hh:mm a').format(now.toLocal());
    final Reference storageRef = storage
        .ref()
        .child('$folderName/$time.jpg'); // Use folder name in the path

    final metadata = SettableMetadata(
      customMetadata: {
        'Date taken': time,
        'Section': section,
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
      Navigator.of(context).pop(false);
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  Future<void> _captureImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8.0),
            Text('Processing image...'),
          ],
        ),
      ),
    );

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // Initialize the face detector
      final faceDetector = GoogleMlKit.vision.faceDetector();

      final List<Face> faces = await faceDetector.processImage(inputImage);

      // Check if at least one face is detected
      if (faces.isNotEmpty) {
        // Upload the image to Firebase Storage with metadata
        await uploadImageToFirebaseStorage(File(image.path));
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Continue'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // No face detected
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Face Detected'),
            content: const Text('Please capture an image with a valid face.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        // Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
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
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: CameraPreview(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: _captureImage,
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
