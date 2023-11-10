class ClassModel {
  final String id;
  final String email;
  final String name;
  final String student_id;
  final String section_id;
  final String admin_id;
  final String admin_name;
  final String admin_email;

  ClassModel({
    required this.id,
    required this.email,
    required this.name,
    required this.student_id,
    required this.section_id,
    required this.admin_id,
    required this.admin_name,
    required this.admin_email,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'name': name,
        'student_id': student_id,
        'section_id': section_id,
        'admin_id': admin_id,
        'admin_name': admin_name,
        'admin_email': admin_email
      };

  static ClassModel fromJson(Map<String, dynamic> json) => ClassModel(
      // id: json['id'],
      id: json['id'],
      email: json['email'],
      name: json['name'],
      student_id: json['student_id'],
      section_id: json['section_id'],
      admin_id: json['admin_id'],
      admin_name: json['admin_name'],
      admin_email: json['admin_email']);
}
