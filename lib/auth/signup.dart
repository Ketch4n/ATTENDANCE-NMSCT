// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/auth/google/pin_map.dart';
import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/controller/Signup.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  StepperType stepperType = StepperType.horizontal;

  final Key _email = GlobalKey();
  final Key _pass = GlobalKey();

  bool _isObscure = true;
  bool _default = true;
  bool _show = true;

  int _currentStep = 0;
  String emailStatus = '';
  String location = '';
  late String coordinate = '';
  // String LatLng = '';
  late String lat = '';
  late String lng = '';

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _controllController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final inputController = StreamController<String>();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  Future<void> _ref() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  type: stepperType,
                  // physics: const ScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: tapped,
                  onStepContinue: continued,
                  onStepCancel: cancel,
                  steps: <Step>[
                    Step(
                      title: const Text('Email'),
                      content: Column(
                        children: <Widget>[
                          TextFormField(
                              controller: _emailController,
                              key: _email,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (email) => email != null &&
                                      !EmailValidator.validate(email)
                                  ? 'Enter a valid email'
                                  : emailStatus == ""
                                      ? null
                                      : emailStatus,
                              onChanged: (email) {
                                checkEmailAvailability(email);
                              },
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Email Address')),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passController,
                            key: _pass,
                            obscureText: _isObscure,
                            enableSuggestions: false,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value != null && value.length < 6
                                    ? 'Minimum of 6 characters'
                                    : null,
                            decoration: Style.textdesign.copyWith(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text('Details'),
                      content: Column(
                        children: <Widget>[
                          // Stack(
                          //   children: [
                          //     TextFormField(
                          //       readOnly: true,
                          //       enableInteractiveSelection: false,
                          //       // enabled: false,
                          //       controller: _roleController,
                          //       decoration: Style.textdesign
                          //           .copyWith(labelText: 'Role'),
                          //     ),
                          //     Positioned(
                          //       top: 0,
                          //       right: 0,
                          //       child: PopupMenuButton<String>(
                          //         icon: const Icon(
                          //           Icons.arrow_drop_down,
                          //           color: Color.fromARGB(255, 114, 123, 130),
                          //         ),
                          //         onSelected: (String newValue) {
                          //           setState(() {
                          //             _roleController.text = newValue;
                          //           });
                          //         },
                          //         itemBuilder: (BuildContext context) {
                          //           return <PopupMenuEntry<String>>[
                          //             const PopupMenuItem<String>(
                          //               value: "Student",
                          //               child: Text("Student"),
                          //             ),
                          //             const PopupMenuItem<String>(
                          //               value: "Admin",
                          //               child: Text("Admin"),
                          //             ),
                          //             const PopupMenuItem<String>(
                          //               value: "Establishment",
                          //               child: Text("Establishment"),
                          //             ),
                          //           ];
                          //         },
                          //       ),
                          //     )
                          //   ],
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              controller: _fnameController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'First Name'),
                            ),
                          ),
                          TextFormField(
                            controller: _lnameController,
                            decoration: Style.textdesign
                                .copyWith(labelText: 'Last Name'),
                          ),
                          // TextFormField(
                          //   controller: _idController,
                          //   decoration: Style.textdesign.copyWith(
                          //     labelText: 'ID',
                          //     suffixIcon: IconButton(
                          //       icon: const Icon(Icons.refresh),
                          //       onPressed: () {
                          //         String id = generateId();
                          //         _idController.text = id;
                          //       },
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text("Account"),
                      content: Column(
                        children: [
                          TextFormField(
                            controller: _roleController,
                            readOnly: true,
                            decoration: Style.textdesign.copyWith(
                              hintText: _default ? 'Administrator' : 'Intern',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {
                                    _default = !_default;
                                    // _roleController.text =
                                    //     _default ? 'Administrator' : 'Intern';
                                  });
                                  // String id = generateId();
                                  // _roleController.text = id;
                                },
                              ),
                            ),
                          ),
                          _default && !_show
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    controller: _locationController,
                                    readOnly: true,
                                    decoration: Style.textdesign.copyWith(
                                        hintText: User.location == ""
                                            ? 'Address'
                                            : User.location),
                                  ),
                                )
                              : SizedBox(),

                          _default && !_show
                              ? TextFormField(
                                  controller: _controllController,
                                  decoration: Style.textdesign.copyWith(
                                      labelText: 'Establishment name'),
                                )
                              : SizedBox(),

                          const SizedBox(height: 20),

                          Container(
                            decoration: Style.boxdecor,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: _default
                                    ? IconButton(
                                        color: Colors.redAccent,
                                        iconSize: 50,
                                        icon: const Icon(Icons.location_pin),
                                        onPressed: () async {
                                          final value = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PinMap()),
                                          );
                                          if (value != null) {
                                            setState(() {
                                              _show = false;
                                            });
                                          }
                                        },
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PinMap()),
                                          );
                                        },
                                        child:
                                            Lottie.asset('assets/scan.json')),
                              ),
                            ),
                          ),
                          // Stack(
                          //   children: [
                          //     TextFormField(
                          //       readOnly: true,
                          //       enableInteractiveSelection: false,
                          //       // enabled: false,
                          //       controller: _roleController,
                          //       decoration: Style.textdesign
                          //           .copyWith(labelText: 'Role'),
                          //     ),
                          //     Positioned(
                          //       top: 0,
                          //       right: 0,
                          //       child: PopupMenuButton<String>(
                          //         icon: const Icon(
                          //           Icons.arrow_drop_down,
                          //           color: Color.fromARGB(255, 114, 123, 130),
                          //         ),
                          //         onSelected: (String newValue) {
                          //           setState(() {
                          //             _roleController.text = newValue;
                          //           });
                          //         },
                          //         itemBuilder: (BuildContext context) {
                          //           return <PopupMenuEntry<String>>[
                          //             const PopupMenuItem<String>(
                          //               value: "Intern",
                          //               child: Text("Intern"),
                          //             ),
                          //             const PopupMenuItem<String>(
                          //               value: "Administrator",
                          //               child: Text("Administrator"),
                          //             ),
                          //           ];
                          //         },
                          //       ),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                      state: _currentStep >= 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: switchStepsType,
      //   child: const Icon(Icons.list),
      // ),
    );
  }

  // void switchStepsType() {
  //   setState(() => stepperType = stepperType == StepperType.vertical
  //       ? StepperType.horizontal
  //       : StepperType.vertical);
  // }

  void tapped(int step) {
    setState(() => _currentStep = step);
  }

  void cancel() {
    _currentStep > 0
        ? setState(() => _currentStep -= 1)
        : _currentStep == 0
            ? Navigator.of(context).pop(false)
            : null;
  }

  Future<void> checkEmailAvailability(String email) async {
    final response = await http.post(
      Uri.parse('${Server.host}auth/check_email.php'),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];

      setState(() {
        emailStatus = message;
      });
    }
  }

  Future<void> continued() async {
    FocusScope.of(context).unfocus();
    String email = _emailController.text.trim();
    String password = _passController.text.trim();

    String name = _fnameController.text.trim();
    String id = _lnameController.text.trim();
    String role = _roleController.text.trim();
    String loc = User.location.trim();
    String cont = _controllController.text.trim();

    if ((email.isEmpty || password.isEmpty) && _currentStep == 0) {
      String title = email.isEmpty ? "Email Empty !" : "Password Empty !";
      String message = "Please Enter ${email.isEmpty ? "Email" : "Password"}";
      showAlertDialog(context, title, message);
    } else if (emailStatus == 'Email is already taken' && _currentStep == 0) {
      String title = 'Email is already taken';
      String message = 'Select another email';
      showAlertDialog(context, title, message);
    } else if ((name.isEmpty || id.isEmpty) && _currentStep == 1) {
      String message = "Please Enter Account Details";
      String title = name.isEmpty ? "Input First Name" : "Input Last Name";
      showAlertDialog(context, title, message);
    } else if ((loc.isEmpty || cont.isEmpty && _default) && _currentStep == 2) {
      String message = "Please Enter Location Details";
      String title = loc.isEmpty
          ? "Click the location icon and Save"
          : "Input Establishment Name";
      showAlertDialog(context, title, message);
    } else if (_currentStep == 2) {
      await signup(context, email, password, id, name,
          _default ? 'Administrator' : 'Intern');
      String code = generateAlphanumericId();
      String currentCoordinate = User.location;
      double? currentLat = User.latitude;
      double? currentLng = User.longitude;

      // ignore: use_build_context_synchronously
      await CreateSectEstab(
        context,
        code,
        cont,
        currentCoordinate,
        currentLng!,
        currentLat!,
        email,
      );
    } else {
      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
    }
  }
}
