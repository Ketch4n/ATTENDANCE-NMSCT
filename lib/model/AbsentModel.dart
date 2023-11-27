class AbsentModel {
  final String id;
  final String date;
  final String time;
  final String student_id;
  final String section_id;
  final String reason;
  final String status;

  AbsentModel({
    required this.id,
    required this.date,
    required this.time,
    required this.student_id,
    required this.section_id,
    required this.reason,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'date': date,
        'time': time,
        'student_id': student_id,
        'section_id': section_id,
        'reason': reason,
        'status': status,
      };

  static AbsentModel fromJson(Map<String, dynamic> json) => AbsentModel(
      // id: json['id'],
      id: json['id'],
      date: json['date'],
      time: json['time'],
      student_id: json['student_id'],
      section_id: json['section_id'],
      reason: json['reason'],
      status: json['status']);
}
