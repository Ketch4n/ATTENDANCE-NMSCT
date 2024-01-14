import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/locator.dart';
import 'package:attendance_nmsct/pages/db/databse_helper.dart';
import 'package:attendance_nmsct/pages/sign-in.dart';
import 'package:attendance_nmsct/pages/sign-up.dart';
import 'package:attendance_nmsct/services/camera.service.dart';
import 'package:attendance_nmsct/services/face_detector_service.dart';
import 'package:attendance_nmsct/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FaceLauncherPage extends StatefulWidget {
  FaceLauncherPage(
      {Key? key, required this.purpose, required this.refreshCallback})
      : super(key: key);
  final String purpose;
  final VoidCallback refreshCallback;
  @override
  _FaceLauncherPageState createState() => _FaceLauncherPageState();
}

class _FaceLauncherPageState extends State<FaceLauncherPage> {
  MLService _mlService = locator<MLService>();
  FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  CameraService _cameraService = locator<CameraService>();
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
                      Image(image: AssetImage('assets/logo.png')),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
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
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      widget.purpose == 'signup'
                                          ? SignUp()
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
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.purpose == 'signup'
                                        ? 'Register Face'
                                        : 'Face Auth Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
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
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
