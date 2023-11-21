// // ignore_for_file: depend_on_referenced_packages

// import 'package:camera/camera.dart';

// Future _initializeCamera() async {
//   final cameras = await availableCameras();
//   final frontCamera = cameras.firstWhere(
//     (camera) => camera.lensDirection == CameraLensDirection.front,
//     orElse: () => cameras.first,
//   );

//   _controller = CameraController(
//     frontCamera,
//     ResolutionPreset.medium,
//   );

//   await _controller.initialize();
// }
