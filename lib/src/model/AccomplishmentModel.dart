class AccomplishmentModel {
  final int id;
  final String email;
  final String section_id;
  final String week;
  final String comment;
  final String hte_name;
  final String assigned_area;
  final String supervisor;
  final String date;
  final String time;

  AccomplishmentModel({
    required this.id,
    required this.email,
    required this.section_id,
    required this.week,
    required this.comment,
    required this.hte_name,
    required this.assigned_area,
    required this.supervisor,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'section_id': section_id,
        'week': week,
        'comment': comment,
        'hte_name': hte_name,
        'assigned_area': assigned_area,
        'supervisor': supervisor,
        'date': date,
        'time': time,
      };

  static AccomplishmentModel fromJson(Map<String, dynamic> json) =>
      AccomplishmentModel(
        id: json['id'],
        email: json['email'],
        section_id: json['section_id'],
        week: json['week'],
        comment: json['comment'],
        hte_name: json['hte_name'],
        assigned_area: json['assigned_area'],
        supervisor: json['supervisor'],
        date: json['date'],
        time: json['time'],
      );
}
