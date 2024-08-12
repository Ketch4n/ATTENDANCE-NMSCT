class AllStudentModel {
  final String id;
  final String fname;
  final String lname;
  final String email;
  final String bday;
  final String uid;
  final String address;
  final String section;
  final String? establishment_id;
  final String status;

  AllStudentModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.bday,
    required this.uid,
    required this.address,
    required this.section,
    this.establishment_id,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fname': fname,
        'lname': lname,
        'email': email,
        'bday': bday,
        'uid': uid,
        'address': address,
        'section': section,
        'establishment_id': establishment_id,
        'status': status,
      };

  static AllStudentModel fromJson(Map<String, dynamic> json) => AllStudentModel(
        id: json['id'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        bday: json['bday'],
        uid: json['uid'],
        address: json['address'],
        section: json['section'],
        establishment_id: json['establishment_id'],
        status: json['status'],
      );
}
