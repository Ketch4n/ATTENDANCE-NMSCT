// ignore_for_file: use_build_context_synchronously

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/camera_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

  bool _processingImage = false;
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

  Future<void> faceAuth() async {
    try {
      Navigator.of(context).pop(false);
    } catch (e) {
      // print('Error uploading image to database: $e');
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

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => SizedBox(
    //         height: 50, width: 50, child: Image.asset('assets/loading.gif')));

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
        final message = "Face ID : ${Session.name}";
        widget.refreshCallback();
        // Upload the image to Firebase Storage with metadata
        await cameraAlertDialog(context, title, message);
        await faceAuth();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Auth'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !_processingImage) {
            return Column(
              children: [
                Center(
                  child: Expanded(
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
                ),
                const ListTile(
                    leading: Text("Current Location :"),
                    trailing: Text("Offline"))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
