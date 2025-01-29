// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/auth/google/map_google.dart';
import 'package:attendance_nmsct/src/controller/Signup.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/data/provider/settings.dart';
import 'package:attendance_nmsct/src/functions/generate.dart';
import 'package:attendance_nmsct/src/model/AdminModel.dart';
import 'package:attendance_nmsct/src/view/administrator/admin_page.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/model/CoursesModel.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/estab/courses/functions/get_courses.dart';
import 'package:attendance_nmsct/src/view/school_year/functions/fetch_all.dart';
import 'package:attendance_nmsct/src/view/school_year/model/school_year_model.dart';
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
  final StreamController<List<SchoolYearModel>> _schoolYearStreamController =
      StreamController<List<SchoolYearModel>>.broadcast();

  Stream<List<SchoolYearModel>> get schoolYearStream =>
      _schoolYearStreamController.stream;

  @override
  void dispose() {
    _schoolYearStreamController.close();
    super.dispose();
  }

  bool _isObscure = true;
  bool _show = true;
  String emailStatus = '';
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _controllController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _locationController = TextEditingController();
  final _idnumberController = TextEditingController();
  final _contactController = TextEditingController();
  final _sectionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _radiusController = TextEditingController();
  final _courseController = TextEditingController();
  final _semesterController = TextEditingController();
  final _schoolYearController = TextEditingController();
  final _facultyController = TextEditingController();

  final List<String> _semester = ["1st Semester", "2nd Semester"];
  String? _selectedSemester;

  late List<CoursesModel> _course = [];
  String? _selectedCourseId;

  late List<SchoolYearModel> _schoolYear = [];
  String? _selectedYearId;

  late List<AdminModel> _faculty = [];
  String? _selectedFaculty;

  @override
  void initState() {
    super.initState();
    getCoursesFromAPI();
    getSchoolYearFromAPI();
    getFacultyFromAPI();
  }

  Future<void> getCoursesFromAPI() async {
    List<CoursesModel> courses = await getCourses();
    setState(() {
      _course = courses;
    });
  }

  Future<void> getSchoolYearFromAPI() async {
    List<SchoolYearModel> schoolYear =
        await getSchoolYear(_schoolYearStreamController);
    setState(() {
      _schoolYear = schoolYear;
    });
  }

  Future<void> getFacultyFromAPI() async {
    List<AdminModel> faculty = await fetchAdmins();
    setState(() {
      _faculty = faculty;
    });
  }

  Future<List<AdminModel>> fetchAdmins() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/admin/all_faculty.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => AdminModel.fromJson(e)).toList();
      } else {
        throw Exception(
            'Error: ${response.statusCode}, Message: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
      return [];
    }
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
                  : widget.purpose == 'FACULTY'
                      ? const Text("Add Faculty Account")
                      : const Text("Add Admin Account"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : emailStatus == ""
                                ? null
                                : emailStatus,
                    onChanged: (email) {
                      checkEmailAvailability(email);
                    },
                    decoration:
                        Style.textdesign.copyWith(labelText: 'Email Address'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passController,
                    obscureText: _isObscure,
                    enableSuggestions: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length < 6
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fnameController,
                    decoration:
                        Style.textdesign.copyWith(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lnameController,
                    decoration:
                        Style.textdesign.copyWith(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 10),
                  widget.purpose == 'INTERN'
                      ? Column(
                          children: [
                            TextFormField(
                              controller: _idnumberController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'ID Number'),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _contactController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11)
                              ],
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Contact Number'),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedCourseId,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Course'),
                              items: _course.map((CoursesModel course) {
                                return DropdownMenuItem<String>(
                                  value: course.id,
                                  child: Text(course.courses),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCourseId = newValue;
                                  _courseController.text = newValue ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _sectionController,
                              decoration:
                                  Style.textdesign.copyWith(labelText: 'Block'),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedSemester,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Semester'),
                              items: _semester.map((String semester) {
                                return DropdownMenuItem<String>(
                                  value: semester,
                                  child: Text(semester),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSemester = newValue;
                                  _semesterController.text = newValue ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedYearId,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'School Year'),
                              items: _schoolYear.map((SchoolYearModel year) {
                                return DropdownMenuItem<String>(
                                  value: year.year,
                                  child: Text(year.year),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedYearId = newValue;
                                  _schoolYearController.text = newValue ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedFaculty,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Faculty'),
                              items: _faculty.map((AdminModel year) {
                                return DropdownMenuItem<String>(
                                  value: year.email,
                                  child: Text("${year.lname}, ${year.fname}"),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFaculty = newValue;
                                  _facultyController.text = newValue ?? '';
                                });
                              },
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10),
                  widget.purpose == 'ESTAB'
                      ? Column(
                          children: [
                            TextFormField(
                              controller: _locationController,
                              readOnly: true,
                              decoration: Style.textdesign.copyWith(
                                hintText: UserSession.location == ""
                                    ? 'Address'
                                    : UserSession.location,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _controllController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Establishment name'),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: _hoursController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Hours Required'),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: _radiusController,
                              decoration: Style.textdesign.copyWith(
                                  labelText: 'Radius (default 5 meters)'),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: Style.boxdecor,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: IconButton(
                                    color: Colors.redAccent,
                                    iconSize: 50,
                                    icon: const Icon(Icons.location_pin),
                                    onPressed: () async {
                                      final value = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MapScreen()),
                                      );
                                      if (value != null) {
                                        setState(() {
                                          _show = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child:
                                  Text("Click the icon to register Location"),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () => continued(user: widget.purpose),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
    String faculty = _facultyController.text.trim();

    if ((widget.purpose != "ESTAB") && (email.isEmpty || password.isEmpty)) {
      String title = email.isEmpty ? "Email Empty !" : "Password Empty !";
      String message = "Please Enter ${email.isEmpty ? "Email" : "Password"}";
      showAlertDialog(context, title, message);
    } else if (emailStatus == 'Email is already taken') {
      String title = 'Email is already taken';
      String message = 'Select another email';
      showAlertDialog(context, title, message);
    } else if ((widget.purpose != "ESTAB") && (name.isEmpty || id.isEmpty)) {
      String message = "Please Enter Account Details";
      String title = name.isEmpty ? "Input First Name" : "Input Last Name";
      showAlertDialog(context, title, message);
    } else if (user == "INTERN" && (contact_number.isEmpty)) {
      String message = "Please Enter Account Information";
      String title = "Input details";
      showAlertDialog(context, title, message);
    } else if (user == "INTERN" &&
        (course.isEmpty ||
            section.isEmpty ||
            semester.isEmpty ||
            schoolYear.isEmpty ||
            faculty.isEmpty)) {
      String message = "Please Enter Account Details";
      String title = "Input details";
      showAlertDialog(context, title, message);
    } else if (user == 'ESTAB' &&
        (loc.isEmpty || cont.isEmpty || hours.isEmpty)) {
      String title = "Please Enter Location Details";
      String message = loc.isEmpty
          ? "Click the location icon and Save"
          : cont.isEmpty
              ? "Input Establishment Name"
              : "Hours required for Interns";
      showAlertDialog(context, title, message);
    } else {
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
            faculty,
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
            faculty,
            widget.purpose);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Auth()));
      }
    }
  }
}
