import 'package:attendance_nmsct/controller/Login.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/locator.dart';
import 'package:attendance_nmsct/pages/models/user.model.dart';
import 'package:attendance_nmsct/pages/profile.dart';
import 'package:attendance_nmsct/pages/widgets/app_button.dart';
import 'package:attendance_nmsct/pages/widgets/app_text_field.dart';
import 'package:attendance_nmsct/services/camera.service.dart';
import 'package:flutter/material.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet(
      {Key? key,
      required this.user,
      required this.purpose,
      required this.refresh})
      : super(key: key);
  final User user;
  final String purpose;
  final VoidCallback refresh;

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      login(context, user.user, user.password);

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => Profile(
      //               user.user,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.user,
            style: TextStyle(
                fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          Text(
            'Face Email Detected',
            style: TextStyle(color: Colors.green),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 10),
                purpose == 'signin'
                    ? AppTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        isPassword: true,
                      )
                    : Text(user.user == Session.email
                        ? 'FACE AND EMAIL MATCHED'
                        : "UNMATCHED"),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                purpose == 'signin'
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context, user);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : AppButton(
                        text: 'Time-in/out',
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);

                          refresh();
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
