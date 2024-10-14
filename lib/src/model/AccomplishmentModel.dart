class AccomplishmentModel {
  final String id;
  final String email;
  final String section_id;
  final String week;
  final String comment;
  final String date;
  final String time;

  AccomplishmentModel(
      {required this.id,
      required this.email,
      required this.section_id,
      required this.week,
      required this.comment,
      required this.date,
      required this.time});

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'section_id': section_id,
        'comment': comment,
        'date': date,
        'time': time,
      };

  static AccomplishmentModel fromJson(Map<String, dynamic> json) =>
      AccomplishmentModel(
        // id: json['id'],
        id: json['id'],
        email: json['email'],
        section_id: json['section_id'],
        week: json['week'],
        comment: json['comment'],
        date: json['date'],
        time: json['time'],
      );
}
