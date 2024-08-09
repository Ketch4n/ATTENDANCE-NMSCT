import 'dart:math';
import 'dart:typed_data';

import 'package:attendance_nmsct/face_recognition/db/databse_helper.dart';
import 'package:attendance_nmsct/face_recognition/pages/models/user.model.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;

class MLService {
  double threshold = 0.5;
  List<double> _predictedData = [];
  List<double> get predictedData => _predictedData;

  Future<void> initialize() async {
    try {
      // If you need GPU delegates or custom interpreters, add their setup here.
      // Example:
      // if (Platform.isAndroid) {
      //   // Configure Android-specific options here
      // } else if (Platform.isIOS) {
      //   // Configure iOS-specific options here
      // }
    } catch (e) {
      print('Failed to initialize model.');
      print(e);
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, Face? face) {
    if (face == null) throw Exception('Face is null');
    List<double> input = _preProcess(cameraImage, face);

    // Replace this with actual ML model prediction if needed
    List<double> output = List.filled(192, 0.0);

    _predictedData = List.from(output);
  }

  Future<User?> predict() async {
    return _searchResult(_predictedData);
  }

  List<double> _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList
        .toList()
        .cast<double>(); // Convert Float32List to List<double>
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(convertedImage,
        x: x.toInt(), y: y.toInt(), width: w.toInt(), height: h.toInt());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    return imglib.copyRotate(img, angle: -90);
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    // Create a Float32List with the size needed
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    // Iterate over each pixel in the image
    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        // Get the pixel data
        int pixel = image.getPixel(j, i) as int;

        // Extract RGB values manually
        int r = (pixel >> 16) & 0xFF; // Extract red
        int g = (pixel >> 8) & 0xFF; // Extract green
        int b = pixel & 0xFF; // Extract blue

        // Normalize and set pixel values
        buffer[pixelIndex++] = (r - 128) / 128.0;
        buffer[pixelIndex++] = (g - 128) / 128.0;
        buffer[pixelIndex++] = (b - 128) / 128.0;
      }
    }
    return convertedBytes;
  }

  Future<User?> _searchResult(List<double> predictedData) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<User> users = await dbHelper.queryAllUsers();
    double minDist = double.infinity;
    User? predictedResult;

    print('users.length => ${users.length}');

    for (User u in users) {
      double currDist =
          _euclideanDistance(u.modelData.cast<double>(), predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = u;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List<double>? e1, List<double>? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(List<double> value) {
    _predictedData = value;
  }

  void dispose() {
    // Clean up any resources here if needed
  }

  convertToImage(CameraImage image) {}
}
