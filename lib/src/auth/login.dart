import 'dart:convert';

import 'package:attendance_nmsct/src/controller/Login.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/settings.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/include/style.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

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

  forgotPass() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Provide the email above")));
    } else {
      try {
        final response = await http.post(
          Uri.parse("${Server.host}auth/forgot_pass.php"),
          body: jsonEncode({"email": _emailController.text}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Check Email")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<UserRole>(
      builder: (context, user, child) {
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
                            Text("OJT Attendance\nMonitoring",
                                style: Style.text),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("OJT COORDINATOR / INSTRUCTOR / FACULTY",
                            style: Style.text),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Padding(
                          padding: Style.padding,
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailController,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: Style.textdesign
                                    .copyWith(hintText: "Username"),
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
                              const SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                onPressed: () async {
                                  final email = _emailController.text.trim();
                                  final password = _passController.text.trim();
                                  await login(
                                      context, email, password, user.role);
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
                              const SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                  onPressed: () {
                                    forgotPass();
                                  },
                                  child: Text('Forgot Password ?'))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
