// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/controller/Signup.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  int _currentStep = 0;
  String emailStatus = '';

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final inputController = StreamController<String>();
  final _roleController = TextEditingController();

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
                      title: const Text('Account'),
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
                          Stack(
                            children: [
                              TextFormField(
                                readOnly: true,
                                enableInteractiveSelection: false,
                                // enabled: false,
                                controller: _roleController,
                                decoration: Style.textdesign
                                    .copyWith(labelText: 'Role'),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color.fromARGB(255, 114, 123, 130),
                                  ),
                                  onSelected: (String newValue) {
                                    setState(() {
                                      _roleController.text = newValue;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: "Student",
                                        child: Text("Student"),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: "Admin",
                                        child: Text("Admin"),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: "Establishment",
                                        child: Text("Establishment"),
                                      ),
                                    ];
                                  },
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              controller: _nameController,
                              decoration:
                                  Style.textdesign.copyWith(labelText: 'Name'),
                            ),
                          ),
                          TextFormField(
                            controller: _idController,
                            decoration: Style.textdesign.copyWith(
                              labelText: 'ID',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  String id = generateId();
                                  _idController.text = id;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Text(_currentStep == 2 ? "Confirm" : "Pending"),
                      content: const SizedBox(),
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
    String id = _idController.text.trim();
    String name = _nameController.text.trim();
    String role = _roleController.text.trim();

    if ((email.isEmpty || password.isEmpty) && _currentStep == 0) {
      String title = email.isEmpty ? "Email Empty !" : "Password Empty !";
      String message = "Please Enter ${email.isEmpty ? "Email" : "Password"}";
      showAlertDialog(context, title, message);
    } else if (emailStatus == 'Email is already taken' && _currentStep == 0) {
      String title = 'Email is already taken';
      String message = 'Select another email';
      showAlertDialog(context, title, message);
    } else if ((role.isEmpty || name.isEmpty || id.isEmpty) &&
        _currentStep == 1) {
      String message = "Please Enter Account Details";
      String title = role.isEmpty
          ? "Select Role"
          // : _roleController.text != 'Student' ||
          //         _roleController.text != 'Admin' ||
          //         _roleController.text != 'Establishment'
          //     ? "Role Invalid"
          : name.isEmpty
              ? "Name is Empty"
              : _roleController.text == 'Establishment'
                  ? "Select Location"
                  : "Input ID";
      showAlertDialog(context, title, message);
    } else if (_currentStep == 2) {
      await signup(context, email, password, id, name, _roleController.text);
    } else {
      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
    }
  }
}
