class AllStudentModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final String id_number;
  final String course;
  final String courses;

  final String contact_number;
  final String section;
  final String semester;
  final String school_year;
  final String? establishment_id;
  final String? establishment_name;
  final String status;

  AllStudentModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.id_number,
    required this.course,
    required this.courses,
    required this.contact_number,
    required this.section,
    required this.semester,
    required this.school_year,
    this.establishment_id,
    this.establishment_name,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fname': fname,
        'lname': lname,
        'email': email,
        'id_number': id_number,
        'course': course,
        'courses': courses,
        'contact_number': contact_number,
        'section': section,
        'semester': semester,
        'school_year': school_year,
        'establishment_id': establishment_id,
        'establishment_name': establishment_name,
        'status': status,
      };

  static AllStudentModel fromJson(Map<String, dynamic> json) => AllStudentModel(
        id: json['id'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        id_number: json['id_number'],
        course: json['course'],
        courses: json['courses'],
        contact_number: json['contact_number'],
        section: json['section'],
        semester: json['semester'],
        school_year: json['school_year'],
        establishment_id: json['establishment_id'],
        establishment_name: json['establishment_name'],
        status: json['status'],
      );
}
