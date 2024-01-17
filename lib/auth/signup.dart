// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/auth/google/pin_map.dart';
import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/controller/Signup.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/pages/home.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key, required this.purpose}) : super(key: key);
  final String purpose;
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
  bool done = true;
  bool clicked = false;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _controllController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final inputController = StreamController<String>();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _bdayController = TextEditingController();
  final _uidController = TextEditingController();
  final _uaddressController = TextEditingController();

  Future<void> _ref() async {
    setState(() {});
  }

  DateTime _date = DateTime.now();

  TimeOfDay _time = TimeOfDay.now();

  Future _showDatePicker() async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        // Save the selected date
        setState(() {
          _date = value;
          _bdayController.text = "${value.month}/${value.day}/${value.year}";
        });

        // Show a custom modal with a text field
        // _showCustomModal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: widget.purpose == 'Create'
            ? Text('Create Account')
            : Text('Register Intern'),
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
                          UserRole.role == 'Intern'
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    controller: _uidController,
                                    decoration: Style.textdesign
                                        .copyWith(labelText: 'Intern ID'),
                                  ),
                                )
                              : SizedBox(),

                          TextFormField(
                            controller: _fnameController,
                            decoration: Style.textdesign
                                .copyWith(labelText: 'First Name'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              controller: _lnameController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Last Name'),
                            ),
                          ),

                          UserRole.role == 'Intern'
                              ? TextFormField(
                                  readOnly: true,
                                  controller: _bdayController,
                                  decoration: Style.textdesign.copyWith(
                                    hintText: !clicked
                                        ? 'Birth Date'
                                        : '${_bdayController.text}',
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.calendar_month),
                                      onPressed: () {
                                        clicked = !clicked;
                                        _showDatePicker();
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          UserRole.role == 'Intern'
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    controller: _uaddressController,
                                    decoration: Style.textdesign
                                        .copyWith(labelText: 'Address'),
                                  ),
                                )
                              : SizedBox(),
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
                          // TextFormField(
                          //   controller: _roleController,
                          //   readOnly: true,
                          //   decoration: Style.textdesign.copyWith(
                          //     hintText: _default ? 'Administrator' : 'Intern',
                          //     suffixIcon: IconButton(
                          //       icon: const Icon(Icons.refresh),
                          //       onPressed: () {
                          //         setState(() {
                          //           _default = !_default;
                          //           _roleController.text =
                          //               _default ? 'Administrator' : 'Intern';
                          //         });
                          //         // String id = generateId();
                          //         // _roleController.text = id;
                          //       },
                          //     ),
                          //   ),
                          // ),

                          _default && !_show
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    controller: _locationController,
                                    readOnly: true,
                                    decoration: Style.textdesign.copyWith(
                                        hintText: UserSession.location == ""
                                            ? 'Address'
                                            : UserSession.location),
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

                          UserRole.role != "NMSCST"
                              ? Container(
                                  decoration: Style.boxdecor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: UserRole.role == 'Administrator'
                                            ? IconButton(
                                                color: Colors.redAccent,
                                                iconSize: 50,
                                                icon: const Icon(
                                                    Icons.location_pin),
                                                onPressed: () async {
                                                  final value =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PinMap()),
                                                  );
                                                  if (value != null) {
                                                    setState(() {
                                                      _show = false;
                                                    });
                                                  }
                                                },
                                              )
                                            : GestureDetector(
                                                onTap: () async {
                                                  Session.email =
                                                      _emailController.text
                                                          .trim();
                                                  Session.password =
                                                      _passController.text
                                                          .trim();
                                                  final value1 =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            FaceLauncherPage(
                                                              purpose: 'signup',
                                                              refreshCallback:
                                                                  () {},
                                                            )),
                                                  );
                                                  if (value1 != null) {
                                                    setState(() {
                                                      done = false;
                                                      continued();
                                                    });
                                                  }
                                                },
                                                child: Lottie.asset(
                                                    'assets/scan.json'))),
                                  ),
                                )
                              : SizedBox(),
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
    String loc = UserSession.location.trim();
    String cont = _controllController.text.trim();
    DateTime bday = _date;
    String uid = _uidController.text.trim();
    String address = _uaddressController.text.trim();

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
    } else if (UserRole.role == "Intern" &&
        (uid.isEmpty || address.isEmpty) &&
        _currentStep == 1) {
      String message = "Please Enter Account Details";
      String title = "Input details";
      showAlertDialog(context, title, message);
    } else if (UserRole.role == 'Administrator' &&
        (loc.isEmpty || cont.isEmpty) &&
        _currentStep == 2) {
      String title = "Please Enter Location Details";
      String message = loc.isEmpty
          ? "Click the location icon and Save"
          : "Input Establishment Name";
      showAlertDialog(context, title, message);
    } else if ((UserRole.role == 'Intern' && done) && _currentStep == 2) {
      String title = "Please Register Face";
      String message = "Click icon to scan";
      showAlertDialog(context, title, message);
    } else if (_currentStep == 2) {
      await signup(context, email, password, id, name, UserRole.role, bday, uid,
          address);
      String code = generateAlphanumericId();
      String currentCoordinate = UserSession.location;
      double? currentLat = UserSession.latitude;
      double? currentLng = UserSession.longitude;

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
