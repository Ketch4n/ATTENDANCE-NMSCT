class UnregmModel {
  final String id;
  final String email;
  final String fname;
  final String lname;
  // final String uid;
  final String bday;
  final String address;
  final String section;
  final String course;
  final String semester;
  final String school_year;
  final String role;
  final String password;

  UnregmModel({
    required this.id,
    required this.email,
    required this.fname,
    required this.lname,
    // required this.uid,
    required this.bday,
    required this.address,
    required this.section,
    required this.course,
    required this.semester,
    required this.school_year,
    required this.role,
    required this.password,
  });

  factory UnregmModel.fromJson(Map<String, dynamic> json) {
    return UnregmModel(
      id: json['id'],
      email: json['email'],
      fname: json['fname'],
      lname: json['lname'],
      // uid: json['uid'],
      bday: json['bday'],
      address: json['address'],
      section: json['section'],
      role: json['role'],
      password: json['password'],
      course: json['course'],
      semester: json['semester'],
      school_year: json['school_year'],
    );
  }
}
