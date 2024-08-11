// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/auth/google/map_google.dart';
import 'package:attendance_nmsct/auth/google/pin_map.dart';
import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/controller/Signup.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/admin_list.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/face_recognition/pages/home.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/home.dart';
import 'package:attendance_nmsct/view/administrator/home.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, required this.purpose, required this.reload});
  final String purpose;
  final VoidCallback reload;
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  StepperType stepperType = StepperType.horizontal;

  final Key _email = GlobalKey();
  final Key _pass = GlobalKey();

  bool _isObscure = true;
  final bool _default = true;
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
  // final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _bdayController = TextEditingController();
  final _uidController = TextEditingController();
  final _uaddressController = TextEditingController();
  final _sectionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _radiusController = TextEditingController();

  Future<void> _ref() async {
    setState(() {});
  }

  DateTime _date = DateTime.now();

  // final TimeOfDay _time = TimeOfDay.now();

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
    return Consumer<UserRole>(builder: (context, user, child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: widget.purpose == 'ESTAB'
              ? const Text('REGISTER ESTABLISHMENT')
              : widget.purpose == 'INTERN'
                  ? const Text('Register Intern')
                  : const Text("Add Admin Account"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Expanded(
                  child: Stepper(
                    type: stepperType,
                    // physics: const ScrollPhysics(),
                    currentStep: _currentStep,
                    onStepTapped: tapped,
                    onStepContinue: () => continued(user: widget.purpose),
                    onStepCancel: cancel,
                    steps: widget.purpose != 'ESTAB'
                        ? <Step>[
                            Step(
                              title: widget.purpose != "ESTAB"
                                  ? const Text('Email')
                                  : const Text("Name"),
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
                                      decoration: Style.textdesign.copyWith(
                                          labelText: 'Email Address')),
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
                                  widget.purpose == 'INTERN'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextFormField(
                                            controller: _uidController,
                                            decoration: Style.textdesign
                                                .copyWith(
                                                    labelText: 'Intern ID'),
                                          ),
                                        )
                                      : const SizedBox(),

                                  widget.purpose != 'ESTAB'
                                      ? TextFormField(
                                          controller: _fnameController,
                                          decoration: Style.textdesign.copyWith(
                                              labelText: 'First Name'),
                                        )
                                      : const Text("Proceed"),
                                  widget.purpose != 'ESTAB'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextFormField(
                                            controller: _lnameController,
                                            decoration: Style.textdesign
                                                .copyWith(
                                                    labelText: 'Last Name'),
                                          ),
                                        )
                                      : const Text("Proceed"),

                                  widget.purpose == 'INTERN'
                                      ? TextFormField(
                                          readOnly: true,
                                          controller: _bdayController,
                                          decoration: Style.textdesign.copyWith(
                                            hintText: !clicked
                                                ? 'Birth Date'
                                                : _bdayController.text,
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                  Icons.calendar_month),
                                              onPressed: () {
                                                clicked = !clicked;
                                                _showDatePicker();
                                              },
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  widget.purpose == 'INTERN'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextFormField(
                                            controller: _uaddressController,
                                            decoration: Style.textdesign
                                                .copyWith(labelText: 'Address'),
                                          ),
                                        )
                                      : const SizedBox(),
                                  widget.purpose == 'INTERN'
                                      ? TextFormField(
                                          controller: _sectionController,
                                          decoration: Style.textdesign
                                              .copyWith(labelText: 'Section'),
                                        )
                                      : const SizedBox(),
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
                                      ? TextFormField(
                                          controller: _locationController,
                                          readOnly: true,
                                          decoration: Style.textdesign.copyWith(
                                              hintText:
                                                  UserSession.location == ""
                                                      ? 'Address'
                                                      : UserSession.location),
                                        )
                                      : const SizedBox(),

                                  _default && !_show
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: TextFormField(
                                            controller: _controllController,
                                            decoration: Style.textdesign
                                                .copyWith(
                                                    labelText:
                                                        'Establishment name'),
                                          ),
                                        )
                                      : const SizedBox(),
                                  _default && !_show
                                      ? TextFormField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          controller: _hoursController,
                                          decoration: Style.textdesign.copyWith(
                                              labelText: 'Hours Required'),
                                        )
                                      : const SizedBox(),

                                  const SizedBox(height: 10),
                                  _default && !_show
                                      ? TextFormField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          controller: _radiusController,
                                          decoration: Style.textdesign.copyWith(
                                              labelText:
                                                  'Radius (default 5 meters)'),
                                        )
                                      : const SizedBox(),

                                  const SizedBox(height: 20),

                                  widget.purpose == "ESTAB"
                                      ? Container(
                                          decoration: Style.boxdecor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: widget.purpose == 'ESTAB'
                                                    ? IconButton(
                                                        color: Colors.redAccent,
                                                        iconSize: 50,
                                                        icon: const Icon(
                                                            Icons.location_pin),
                                                        onPressed: () async {
                                                          final value =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const MapScreen()),
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
                                                              _emailController
                                                                  .text
                                                                  .trim();
                                                          Session.password =
                                                              _passController
                                                                  .text
                                                                  .trim();
                                                          final value1 =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        FaceLauncherPage(
                                                                          purpose:
                                                                              'signup',
                                                                          refreshCallback:
                                                                              () {},
                                                                        )),
                                                          );
                                                          if (value1 != null) {
                                                            setState(() {
                                                              done = false;
                                                              continued(
                                                                  user: widget
                                                                      .purpose);
                                                            });
                                                          }
                                                        },
                                                        child: Lottie.asset(
                                                            'assets/scan.json'))),
                                          ),
                                        )
                                      : const SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(widget.purpose == "ESTAB"
                                        ? "Click the icon to register Location"
                                        : widget.purpose == "Intern"
                                            ? "Click the icon to register Face Auth"
                                            : "Click continue to confirm"),
                                  ),
                                ],
                              ),
                              isActive: _currentStep >= 2,
                              state: _currentStep >= 2
                                  ? StepState.complete
                                  : StepState.disabled,
                            ),
                          ]
                        : <Step>[],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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

  Future<void> continued({required String user}) async {
    FocusScope.of(context).unfocus();
    String email = _emailController.text.trim();
    String password = _passController.text.trim();

    String name = _fnameController.text.trim();
    String id = _lnameController.text.trim();
    String hours = _hoursController.text.trim();

    String loc = UserSession.location.trim();
    String cont = _controllController.text.trim();
    DateTime bday = _date;
    String uid = _uidController.text.trim();
    String address = _uaddressController.text.trim();
    String section = _sectionController.text.trim();
    String radius = _radiusController.text.trim();

    if ((widget.purpose != "ESTAB") &&
        (email.isEmpty || password.isEmpty) &&
        _currentStep == 0) {
      String title = email.isEmpty ? "Email Empty !" : "Password Empty !";
      String message = "Please Enter ${email.isEmpty ? "Email" : "Password"}";
      showAlertDialog(context, title, message);
    } else if (emailStatus == 'Email is already taken' && _currentStep == 0) {
      String title = 'Email is already taken';
      String message = 'Select another email';
      showAlertDialog(context, title, message);
    } else if ((widget.purpose != "ESTAB") &&
        (name.isEmpty || id.isEmpty) &&
        _currentStep == 1) {
      String message = "Please Enter Account Details";
      String title = name.isEmpty ? "Input First Name" : "Input Last Name";
      showAlertDialog(context, title, message);
    } else if (user == "INTERN" &&
        (uid.isEmpty || address.isEmpty || section.isEmpty) &&
        _currentStep == 1) {
      String message = "Please Enter Account Details";
      String title = "Input details";
      showAlertDialog(context, title, message);
    } else if (user == 'ESTAB' &&
        (loc.isEmpty || cont.isEmpty || hours.isEmpty) &&
        _currentStep == 2) {
      String title = "Please Enter Location Details";
      String message = loc.isEmpty
          ? "Click the location icon and Save"
          : cont.isEmpty
              ? "Input Establishment Name"
              : "Hours required for Interns";
      showAlertDialog(context, title, message);
    }
    // else if ((user == 'Intern' && done) && _currentStep == 2) {
    //   String title = "Please Register Face";
    //   String message = "Click icon to scan";
    //   showAlertDialog(context, title, message);
    // }
    else if (_currentStep == 2) {
      // ignore: use_build_context_synchronously
      if (widget.purpose == 'INTERN') {
        await signup(context, email, password, id, name, user, bday, uid,
            address, section, widget.purpose);
        Navigator.of(context).pop(false);

        // Navigator.of(context).pop(false);

        widget.reload();
      } else {
        String code = generateAlphanumericId();
        String currentCoordinate = UserSession.location;
        double? currentLat = UserSession.latitude;
        double? currentLng = UserSession.longitude;
        String radiusMeter = radius.isEmpty ? "5" : radius;

        await signup(context, email, password, id, name, user, bday, uid,
            address, section, widget.purpose);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminList()));

        // await CreateSectEstab(context, code, cont, currentCoordinate,
        //     currentLng!, currentLat!, email, hours, radiusMeter);
        // await signup(context, email, password, id, name, user, bday, uid,
        //     address, section, widget.purpose);
      }
    } else {
      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
    }
  }
}
