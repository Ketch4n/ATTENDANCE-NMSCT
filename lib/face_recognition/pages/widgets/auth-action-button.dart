import 'package:attendance_nmsct/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/controller/Login.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/face_recognition/locator.dart';
import 'package:attendance_nmsct/face_recognition/db/databse_helper.dart';
import 'package:attendance_nmsct/face_recognition/pages/models/user.model.dart';
import 'package:attendance_nmsct/face_recognition/pages/profile.dart';
import 'package:attendance_nmsct/face_recognition/pages/widgets/app_button.dart';
import 'package:attendance_nmsct/face_recognition/services/camera.service.dart';
import 'package:attendance_nmsct/face_recognition/services/ml_service.dart';
import 'package:attendance_nmsct/view/student/home.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';
import 'app_text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthActionButton extends StatefulWidget {
  AuthActionButton({
    Key? key,
    required this.onPressed,
    required this.isLogin,
    required this.reload,
  });
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '${Session.email}');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '${Session.password}');

  User? predictedUser;

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    // FaceDone.status = false;
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);

    final title = "Success";
    final message = "Face Data Registered Successfully";
    const userEmails = ["nmsct.attendance.monitoring@gmail.com"];
    final announce =
        "Student wit an email ${Session.email} has successfully registered his/her Facial Data.\nStudent is status is now ACTIVE ";
    await updateUser();
    sendToAll(userEmails, announce);
    await showAlertDialog(context, title, message);
    // Navigator.pop(context, user);
    // Navigator.pop(context, user);
    // Navigator.pop(context, user);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentHome(),
      ),
    );

    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) => FaceLauncherPage(
    //               purpose: 'signin',
    //             )));
  }
// URL of your PHP script

  Future<void> updateUser() async {
    String apiUrl = '${Server.host}auth/update_status.php';
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userId');
    // final userEMAIL = prefs.getString('userEmail');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': userID,
        'status': "Active",
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        print('Update successful: ${responseData['message']}');
      } else {
        print('Update failed: ${responseData['message']}');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (predictedUser!.password == password) {
      // login(context, predictedUser!.user, password);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => Profile(
      //               this.predictedUser!.user,
      //               imagePath: _cameraService.imagePath!,
      //             )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            this.predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome !!!, ' + predictedUser!.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? Text(Session.email)
                    // AppTextField(
                    //     controller: _userTextEditingController,
                    //     labelText: "Your Name",
                    //   )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : Text(Session.password),
                // AppTextField(
                //     controller: _passwordTextEditingController,
                //     labelText: "Password",
                //     isPassword: true,
                //   ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'SIGN UP',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
