class AllStudentModel {
  final String fname;
  final String lname;
  final String email;
  final String bday;
  final String uid;
  final String address;
  final String section;

  AllStudentModel(
      {required this.fname,
      required this.lname,
      required this.email,
      required this.bday,
      required this.uid,
      required this.address,
      required this.section});

  Map<String, dynamic> toJson() => {
        'fname': fname,
        'lname': lname,
        'email': email,
        'bday': bday,
        'uid': uid,
        'address': address,
        'section': section
      };

  static AllStudentModel fromJson(Map<String, dynamic> json) => AllStudentModel(
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      bday: json['bday'],
      uid: json['uid'],
      address: json['address'],
      section: json['section']);
}
