import 'dart:async';
import 'dart:math';

import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/locator.dart';
import 'package:attendance_nmsct/services/camera.service.dart';
import 'package:attendance_nmsct/services/face_detector_service.dart';
import 'package:attendance_nmsct/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'models/user.model.dart';

import 'widgets/auth_button.dart';
import 'widgets/camera_detection_preview.dart';
import 'widgets/camera_header.dart';
import 'widgets/signin_form.dart';
import 'widgets/single_picture.dart';

import 'package:camera/camera.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.purpose, required this.refreshCallback})
      : super(key: key);
  final String purpose;
  final VoidCallback refreshCallback;

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  CameraService _cameraService = locator<CameraService>();
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();
  Location _location = Location();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  LocationData? _currentLocation;

  double _givenLatitude = double.parse(Session.latitude); // Example latitude
  double _givenLongitude = double.parse(Session.longitude); // Example longitude

  @override
  void initState() {
    super.initState();
    _start();
    _getLocation();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    setState(() => _isInitializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    bool processing = false;
    _cameraService.cameraController!
        .startImageStream((CameraImage image) async {
      if (processing) return; // prevents unnecessary overprocessing.
      processing = true;
      await _predictFacesFromImage(image: image);
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {
    assert(image != null, 'Image is null');
    await _faceDetectorService.detectFacesFromImage(image!);
    if (_faceDetectorService.faceDetected) {
      _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
    }
    if (mounted) setState(() {});
  }

  Future<void> takePicture() async {
    if (_faceDetectorService.faceDetected) {
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(content: Text('No face detected!')));
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  Future<void> onTap() async {
    await takePicture();
    if (_faceDetectorService.faceDetected) {
      User? user = await _mlService.predict();
      var bottomSheetController = scaffoldKey.currentState!
          .showBottomSheet((context) => signInSheet(user: user));
      bottomSheetController.closed.whenComplete(_reload);
    }
  }

  Widget getBodyWidget() {
    if (_isInitializing) return Center(child: CircularProgressIndicator());
    if (_isPictureTaken)
      return SinglePicture(imagePath: _cameraService.imagePath!);
    return CameraDetectionPreview();
  }

  @override
  Widget build(BuildContext context) {
    Widget header = CameraHeader(widget.purpose, onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) fab = AuthButton(onTap: onTap);

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [body, header],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: fab,
    );
  }

  signInSheet({@required User? user}) => user == null
      ? Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Text(
            'User not found 😞',
            style: TextStyle(fontSize: 20),
          ),
        )
      : SignInSheet(
          user: user, purpose: widget.purpose, refresh: widget.refreshCallback);

  void _getLocation() async {
    try {
      _location.onLocationChanged.listen((LocationData locationData) {
        setState(() {
          _currentLocation = locationData;
          // Compare current location with given latitude and longitude
          _compareLocations(locationData.latitude!, locationData.longitude!);
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _compareLocations(double latitude, double longitude) {
    // Compare latitude and longitude with the given location
    if (_givenLatitude == latitude && _givenLongitude == longitude) {
      // User is at the given location
      _showSnackBar('You are just in the radius');
    } else {
      // User is not at the given location
      _showSnackBar('You are too far from the establishment');
    }
  }

  // void _showDistanceSnackBar(double distance) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Distance from given location: $distance meters'),
  //       behavior: SnackBarBehavior.floating,
  //       margin: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).size.height - 200,
  //           left: 10,
  //           right: 10),
  //     ),
  //   );
  // }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: message == 'You are just in the radius'
            ? Colors.green
            : Colors.blue,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 10,
            right: 10),
      ),
    );
  }
}
