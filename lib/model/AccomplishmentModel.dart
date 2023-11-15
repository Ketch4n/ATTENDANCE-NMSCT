class AccomplishmentModel {
  final String id;
  final String email;
  final String section_id;
  final String comment;
  final String date;

  AccomplishmentModel(
      {required this.id,
      required this.email,
      required this.section_id,
      required this.comment,
      required this.date});

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'section_id': section_id,
        'comment': comment,
        'date': date
      };

  static AccomplishmentModel fromJson(Map<String, dynamic> json) =>
      AccomplishmentModel(
          // id: json['id'],
          id: json['id'],
          email: json['email'],
          section_id: json['section_id'],
          comment: json['comment'],
          date: json['date']);
}
