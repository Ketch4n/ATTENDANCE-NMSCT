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
  final String time_rendered_am;
  final String time_rendered_pm;
  final String total_hours_rendered;
  final String date;

  TodayModel({
    this.id = '',
    this.student_id = '',
    this.estab_id = '',
    this.time_in_am = '',
    this.in_am = '',
    this.time_out_am = '',
    this.out_am = '',
    this.time_in_pm = '',
    this.in_pm = '',
    this.time_out_pm = '',
    this.out_pm = '',
    this.time_rendered_am = '',
    this.time_rendered_pm = '',
    this.total_hours_rendered = '',
    this.date = '',
  });

  Map<String, dynamic> toJson() => {
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
        'time_rendered_am': time_rendered_am,
        'time_rendered_pm': time_rendered_pm,
        'total_hours_rendered': total_hours_rendered,
        'date': date,
      };

  static TodayModel fromJson(Map<String, dynamic> json) => TodayModel(
        id: json['id'] ?? '',
        student_id: json['student_id'] ?? '',
        estab_id: json['estab_id'] ?? '',
        time_in_am: json['time_in_am'] ?? '',
        in_am: json['in_am'] ?? '',
        time_out_am: json['time_out_am'] ?? '',
        out_am: json['out_am'] ?? '',
        time_in_pm: json['time_in_pm'] ?? '',
        in_pm: json['in_pm'] ?? '',
        time_out_pm: json['time_out_pm'] ?? '',
        out_pm: json['out_pm'] ?? '',
        time_rendered_am: json['time_rendered_am'] ?? '',
        time_rendered_pm: json['time_rendered_pm'] ?? '',
        total_hours_rendered: json['total_hours_rendered'] ?? '',
        date: json['date'] ?? '',
      );
}
