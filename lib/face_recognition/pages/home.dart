import 'package:attendance_nmsct/face_recognition/locator.dart';
import 'package:attendance_nmsct/face_recognition/pages/sign-in.dart';
import 'package:attendance_nmsct/face_recognition/pages/sign-up.dart';
import 'package:attendance_nmsct/face_recognition/services/camera.service.dart';
import 'package:attendance_nmsct/face_recognition/services/face_detector_service.dart';
import 'package:attendance_nmsct/face_recognition/services/ml_service.dart';
import 'package:flutter/material.dart';

class FaceLauncherPage extends StatefulWidget {
  const FaceLauncherPage(
      {super.key, required this.purpose, required this.refreshCallback});
  final String purpose;
  final VoidCallback refreshCallback;
  @override
  _FaceLauncherPageState createState() => _FaceLauncherPageState();
}

class _FaceLauncherPageState extends State<FaceLauncherPage> {
  final MLService _mlService = locator<MLService>();
  final FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  // void _launchURL() async => await canLaunch(Constants.githubURL)
  //     ? await launch(Constants.githubURL)
  //     : throw 'Could not launch ${Constants.githubURL}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: !loading
          ? SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Image(image: AssetImage('assets/logo.png')),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: const Column(
                          children: [
                            Text(
                              "FACE RECOGNITION AUTHENTICATION",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Text(
                            //   "This device will act as",
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //   ),
                            //   textAlign: TextAlign.center,
                            // ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (BuildContext context) => SignIn(),
                          //       ),
                          //     );
                          //   },
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: Colors.white,
                          //       boxShadow: <BoxShadow>[
                          //         BoxShadow(
                          //           color: Colors.blue.withOpacity(0.1),
                          //           blurRadius: 1,
                          //           offset: Offset(0, 2),
                          //         ),
                          //       ],
                          //     ),
                          //     alignment: Alignment.center,
                          //     padding: EdgeInsets.symmetric(
                          //         vertical: 14, horizontal: 16),
                          //     width: MediaQuery.of(context).size.width * 0.8,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Text(
                          //           'LOGIN',
                          //           style: TextStyle(color:Colors.blue),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Icon(Icons.login, color:Colors.blue)
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      widget.purpose == 'signup'
                                          ? const SignUp()
                                          : SignIn(
                                              refreshCallback:
                                                  widget.refreshCallback,
                                              purpose: widget.purpose,
                                            ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.purpose == 'signup'
                                        ? 'Register Face'
                                        : 'Face Auth Login',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                      widget.purpose == 'signup'
                                          ? Icons.person_add
                                          : Icons.login,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 20,
                          //   width: MediaQuery.of(context).size.width * 0.8,
                          //   child: Divider(
                          //     thickness: 2,
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: _launchURL,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: Colors.black,
                          //       boxShadow: <BoxShadow>[
                          //         BoxShadow(
                          //           color: Colors.blue.withOpacity(0.1),
                          //           blurRadius: 1,
                          //           offset: Offset(0, 2),
                          //         ),
                          //       ],
                          //     ),
                          //     alignment: Alignment.center,
                          //     padding: EdgeInsets.symmetric(
                          //         vertical: 14, horizontal: 16),
                          //     width: MediaQuery.of(context).size.width * 0.8,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Text(
                          //           'CONTRIBUTE',
                          //           style: TextStyle(color: Colors.white),
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         FaIcon(
                          //           FontAwesomeIcons.github,
                          //           color: Colors.white,
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
