class RoomModel {
  final String id;
  final String email;
  final String name;
  final String student_id;
  final String establishment_id;
  final String creator_id;
  final String creator_name;
  final String creator_email;

  RoomModel({
    required this.id,
    required this.email,
    required this.name,
    required this.student_id,
    required this.establishment_id,
    required this.creator_id,
    required this.creator_name,
    required this.creator_email,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'name': name,
        'student_id': student_id,
        'establishment_id': establishment_id,
        'creator_id': creator_id,
        'creator_name': creator_name,
        'creator_email': creator_email
      };

  static RoomModel fromJson(Map<String, dynamic> json) => RoomModel(
      // id: json['id'],
      id: json['id'],
      email: json['email'],
      name: json['name'],
      student_id: json['student_id'],
      establishment_id: json['establishment_id'],
      creator_id: json['creator_id'],
      creator_name: json['creator_name'],
      creator_email: json['creator_email']);
}
