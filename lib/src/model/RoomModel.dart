class RoomModel {
  final String id;
  // final String establishment_id;
  final String email;
  final String fname;
  final String student_id;

  // final String creator_id;
  // final String creator_fname;
  // final String creator_email;

  RoomModel({
    required this.id,
    required this.email,
    required this.fname,
    required this.student_id,
    // required this.establishment_id,
    // required this.creator_id,
    // required this.creator_fname,
    // required this.creator_email,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'fname': fname,
        'student_id': student_id,
        // 'establishment_id': establishment_id,
        // 'creator_id': creator_id,
        // 'creator_fname': creator_fname,
        // 'creator_email': creator_email
      };

  static RoomModel fromJson(Map<String, dynamic> json) => RoomModel(
        // id: json['id'],
        id: json['id'],
        email: json['email'],
        fname: json['fname'],
        student_id: json['student_id'],
        // establishment_id: json['establishment_id'],
        // creator_id: json['creator_id'],
        // creator_fname: json['creator_fname'],
        // creator_email: json['creator_email'],
      );
}
