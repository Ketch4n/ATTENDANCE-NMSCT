import 'package:attendance_nmsct/auth/google/google_map.dart';
import 'package:attendance_nmsct/auth/google/pin_map.dart';
import 'package:attendance_nmsct/auth/signup.dart';
import 'package:attendance_nmsct/controller/Login.dart';
import 'package:attendance_nmsct/data/settings.dart';

import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/pages/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Container(
          height: double.maxFinite,
          decoration: Style.login,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: Style.radius50,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/nmsct.jpg',
                                height: 80,
                                width: 80,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Attendance\nMonitoring", style: Style.text),
                      ],
                    ),
                  ),

                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: Style.padding,
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration:
                                Style.textdesign.copyWith(hintText: "Username"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            obscureText: _isObscure,
                            enableSuggestions: false,
                            controller: _passController,
                            decoration: Style.textdesign.copyWith(
                              hintText: "Password",
                              suffixIcon: IconButton(
                                  icon: Icon(_isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     child:
                          //         Text("Forgot Password ?", style: Style.link),
                          //     onPressed: () {},
                          //   ),
                          // ),
                          TextButton(
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              final password = _passController.text.trim();
                              await login(context, email, password);
                              // ignore: avoid_print
                              print("Clicked");
                            },
                            autofocus: true,
                            style: TextButton.styleFrom(
                                fixedSize: const Size.fromHeight(50),
                                backgroundColor: Style.themecolor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: Style.radius12)),
                            child: Center(
                              child: Text(
                                'LOG IN',
                                style: Style.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(thickness: 2, color: Colors.grey[400]),
                  //     ),
                  //     Text(
                  //       "Or Face Recognition Auth",
                  //       style: Style.subtitle,
                  //     ),
                  //     Expanded(
                  //       child: Divider(thickness: 2, color: Colors.grey[400]),
                  //     ),
                  //   ],
                  // ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Logo(imagePath: 'assets/images/google.png'),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  //     Logo(imagePath: 'assets/images/fb.png'),
                  //   ],
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: null,
                        style: TextButton.styleFrom(textStyle: Style.link),
                        child: Text("create new account ?"),
                      ),
                      TextButton(
                        onPressed: () {
                          final String purpose = 'Create';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Signup(
                                      purpose: purpose,
                                    )),
                          );
                        },
                        style: TextButton.styleFrom(textStyle: Style.link),
                        child: const Text("Sign up"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => FaceLauncherPage(
                  //                 purpose: 'signin',
                  //               )),
                  //     );
                  //   },
                  //   child: Text("FACE"),
                  // )
                  UserRole.role == 'Intern'
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FaceLauncherPage(
                                        purpose: 'signin',
                                        refreshCallback: () {},
                                      )),
                            );
                          },
                          child: Container(
                            decoration: Style.boxdecor,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: kIsWeb
                                    ? Center(child: Text("SCAN"))
                                    : Lottie.asset('assets/scan.json'),
                              ),
                            ),
                          ),
                        )
                      : UserRole.role == 'Administrator'
                          ? SizedBox(
                              height: 150,
                              width: 150,
                              child: Image.asset('assets/settings.png'))
                          : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
