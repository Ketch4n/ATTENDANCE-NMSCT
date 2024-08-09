import 'package:attendance_nmsct/controller/Login.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/face_recognition/locator.dart';
import 'package:attendance_nmsct/face_recognition/pages/models/user.model.dart';
import 'package:attendance_nmsct/face_recognition/pages/widgets/app_button.dart';
import 'package:attendance_nmsct/face_recognition/pages/widgets/app_text_field.dart';
import 'package:attendance_nmsct/face_recognition/services/camera.service.dart';
import 'package:flutter/material.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet(
      {super.key,
      required this.user,
      required this.purpose,
      required this.refresh});
  final User user;
  final String purpose;
  final VoidCallback refresh;

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      login(context, user.user, user.password, UserRole().role);

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
          return const AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.user,
            style: const TextStyle(
                fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Face Email Detected',
            style: TextStyle(color: Colors.green),
          ),
          Container(
            child: Column(
              children: [
                const SizedBox(height: 10),
                purpose == 'signin'
                    ? AppTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        isPassword: true,
                      )
                    : Text(
                        user.user == Session.email
                            ? 'FACE AND EMAIL MATCHED'
                            : "UNMATCHED",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                purpose == 'signin'
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context, user);
                        },
                        icon: const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : user.user == Session.email
                        ? AppButton(
                            text: 'Time-in/out',
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);

                              refresh();
                            },
                            icon: const Icon(
                              Icons.login,
                              color: Colors.white,
                            ),
                          )
                        : const Text('UNMATCH')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
