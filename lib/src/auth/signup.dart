// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/auth/google/map_google.dart';
import 'package:attendance_nmsct/src/controller/Signup.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/data/provider/settings.dart';
import 'package:attendance_nmsct/src/functions/generate.dart';
import 'package:attendance_nmsct/src/include/admin_list.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/CoursesModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/functions/get_courses.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
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
  final _locationController = TextEditingController();
  final _idnumberController = TextEditingController();
  final _contactController = TextEditingController();
  final _sectionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _radiusController = TextEditingController();
  final _courseController = TextEditingController();
  final _semesterController = TextEditingController();
  final _schoolYearController = TextEditingController();

  final List<String> _semester = ["1st Semester", "2nd Semester"];
  String? _selectedSemester;

  late List<CoursesModel> _course = [];
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    getCoursesFromAPI();
  }

  Future<void> getCoursesFromAPI() async {
    List<CoursesModel> courses = await getCourses();
    setState(() {
      _course = courses;
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
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextFormField(
                                            controller: _idnumberController,
                                            decoration: Style.textdesign
                                                .copyWith(
                                                    labelText: 'ID Number'),
                                          ),
                                        )
                                      : const SizedBox(),
                                  widget.purpose == 'INTERN'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextFormField(
                                            controller: _contactController,
                                            decoration: Style.textdesign
                                                .copyWith(
                                                    labelText:
                                                        'Contact Number'),
                                          ),
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
                                  widget.purpose == 'INTERN'
                                      ? DropdownButtonFormField<String>(
                                          value:
                                              _selectedCourseId, // Use the course ID as the value
                                          decoration: const InputDecoration(
                                              labelText: 'Course'),
                                          items: _course
                                              .map((CoursesModel course) {
                                            return DropdownMenuItem<String>(
                                              value: course
                                                  .id, // Use course ID as the value
                                              child: Text(course
                                                  .courses), // Display course name
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedCourseId =
                                                  newValue; // Update selected course ID
                                              _courseController.text = newValue ??
                                                  ''; // Set course ID in the controller
                                              print("ID ${newValue}");
                                            });
                                          },
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: 10),
                                  widget.purpose == 'INTERN'
                                      ? TextFormField(
                                          controller: _sectionController,
                                          decoration: Style.textdesign
                                              .copyWith(labelText: 'Block'),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: 10),
                                  widget.purpose == 'INTERN'
                                      ? DropdownButtonFormField<String>(
                                          value: _selectedSemester,
                                          decoration: Style.textdesign
                                              .copyWith(labelText: 'Semester'),
                                          items:
                                              _semester.map((String semester) {
                                            return DropdownMenuItem<String>(
                                              value: semester,
                                              child: Text(semester),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedSemester = newValue;
                                              _semesterController.text =
                                                  newValue ?? '';
                                            });
                                          },
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: 10),
                                  widget.purpose == 'INTERN'
                                      ? TextFormField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(9),
                                          ],
                                          controller: _schoolYearController,
                                          decoration: Style.textdesign.copyWith(
                                              labelText: 'School Year',
                                              hintText: "Example 2024-2025"),
                                        )
                                      : const SizedBox(),
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
                                                                        MapScreen()),
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
                                                        },
                                                        child: Lottie.asset(
                                                            'assets/scan.json'))),
                                          ),
                                        )
                                      : const SizedBox(),
                                  widget.purpose == "ESTAB"
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                              "Click the icon to register Location"),
                                        )
                                      : const SizedBox(),
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

    String course = _courseController.text.trim();
    String contact_number = _contactController.text.trim();
    String id_number = _idnumberController.text.trim();

    String section = _sectionController.text.trim();
    String radius = _radiusController.text.trim();

    String semester = _semesterController.text.trim();
    String schoolYear = _schoolYearController.text.trim();

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
        (contact_number.isEmpty) &&
        _currentStep == 1) {
      String message = "Please Enter Account Information";
      String title = "Input details";
      showAlertDialog(context, title, message);
    } else if (user == "INTERN" &&
        (course.isEmpty ||
            section.isEmpty ||
            semester.isEmpty ||
            schoolYear.isEmpty) &&
        _currentStep == 2) {
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
    } else if (_currentStep == 2) {
      if (widget.purpose == 'INTERN') {
        await signup(
            context,
            email,
            password,
            id,
            name,
            user,
            id_number,
            course,
            contact_number,
            section,
            semester,
            schoolYear,
            widget.purpose);
        Navigator.of(context).pop(false);

        widget.reload();
      } else {
        String code = generateAlphanumericId();
        String currentCoordinate = UserSession.location;
        double? currentLat = UserSession.latitude;
        double? currentLng = UserSession.longitude;
        String radiusMeter = radius.isEmpty ? "5" : radius;

        await signup(
            context,
            email,
            password,
            id,
            name,
            user,
            id_number,
            course,
            contact_number,
            section,
            semester,
            schoolYear,
            widget.purpose);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminList()));
      }
    } else {
      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
    }
  }
}
