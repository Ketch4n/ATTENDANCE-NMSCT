class TodayModel {
  final String id;
  final String student_id;
  final String estab_id;
  final String time_in_am;
  final String in_am;
  final String time_out_am;
  final String out_am;
  final String time_in_pm;
  final String in_pm;
  final String time_out_pm;
  final String out_pm;
  final String date;

  TodayModel({
    required this.id,
    required this.student_id,
    required this.estab_id,
    required this.time_in_am,
    required this.in_am,
    required this.time_out_am,
    required this.out_am,
    required this.time_in_pm,
    required this.in_pm,
    required this.time_out_pm,
    required this.out_pm,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'student_id': student_id,
        'estab_id': estab_id,
        'time_in_am': time_in_am,
        'in_am': in_am,
        'time_out_am': time_out_am,
        'out_am': out_am,
        'time_in_pm': time_in_pm,
        'in_pm': in_pm,
        'time_out_pm': time_out_pm,
        'out_pm': out_pm,
        'date': date
      };

  static TodayModel fromJson(Map<String, dynamic> json) => TodayModel(
      // id: json['id'],
      id: json['id'],
      student_id: json['student_id'],
      estab_id: json['estab_id'],
      time_in_am: json['time_in_am'],
      in_am: json['in_am'],
      time_out_am: json['time_out_am'],
      out_am: json['out_am'],
      time_in_pm: json['time_in_pm'],
      in_pm: json['in_pm'],
      time_out_pm: json['time_out_pm'],
      out_pm: json['out_pm'],
      date: json['date']);
}
