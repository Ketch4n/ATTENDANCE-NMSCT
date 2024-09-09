class AdminModel {
  final String id;
  final String email;
  final String fname;
  final String lname;
  final String role;
  final String password;

  AdminModel({
    required this.id,
    required this.email,
    required this.fname,
    required this.lname,
    required this.role,
    required this.password,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      email: json['email'],
      fname: json['fname'],
      lname: json['lname'],
      role: json['role'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fname': fname,
        'lname': lname,
        'role': role,
        'password': password,
      };
}
