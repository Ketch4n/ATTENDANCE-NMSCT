import 'dart:async';
import 'dart:math';

import 'package:attendance_nmsct/auth/google/permission.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/locator.dart';
import 'package:attendance_nmsct/services/camera.service.dart';
import 'package:attendance_nmsct/services/face_detector_service.dart';
import 'package:attendance_nmsct/services/ml_service.dart';
import 'package:attendance_nmsct/view/student/calculate_distance.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  late StreamSubscription<Position> _positionStreamSubscription;
  String _locationMessage = '';

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  LocationData? _currentLocation;

  double? _givenLatitude = Session.latitude; // Example latitude
  double? _givenLongitude = Session.longitude; // Example longitude

  @override
  void initState() {
    super.initState();
    _start();
    _startStreamingLocation();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    _stopStreamingLocation();
    super.dispose();
  }

  _startStreamingLocation() async {
    if (widget.purpose == "auth") {
      Position currentPosition =
          await determineUserCurrentPosition(widget.purpose);
      double? estabLat = Session.latitude;
      double? estabLong = Session.longitude;
      var distance = calculateDistance(currentPosition.latitude,
          currentPosition.longitude, estabLat!, estabLong!);
      if (distance <= 5) {
        // User is at the given location
        _showSnackBar('You are In-range of the establishment');
      } else {
        // User is not at the given location
        _showSnackBar('You are too far from the establishment');
      }
    } else {
      return null;
    }
  }

  void _stopStreamingLocation() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: message == 'You are In-range of the establishment'
            ? Colors.blue
            : Colors.orange,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 250,
            left: 10,
            right: 10),
      ),
    );
    // Define the duration for the snackbar
    const snackBarDuration = Duration(seconds: 5);

    // Hide the snackbar after the defined duration
    Future.delayed(snackBarDuration, () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
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
}
