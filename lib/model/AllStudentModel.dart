class AllStudentModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final String bday;
  final String course;
  final String address;
  final String section;
  final String semester;
  final String school_year;
  final String? establishment_id;
  final String status;

  AllStudentModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.bday,
    required this.course,
    required this.address,
    required this.section,
    required this.semester,
    required this.school_year,
    this.establishment_id,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fname': fname,
        'lname': lname,
        'email': email,
        'bday': bday,
        'course': course,
        'address': address,
        'section': section,
        'semester': semester,
        'school_year': school_year,
        'establishment_id': establishment_id,
        'status': status,
      };

  static AllStudentModel fromJson(Map<String, dynamic> json) => AllStudentModel(
        id: json['id'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        bday: json['bday'],
        course: json['course'],
        address: json['address'],
        section: json['section'],
        semester: json['semester'],
        school_year: json['school_year'],
        establishment_id: json['establishment_id'],
        status: json['status'],
      );
}
