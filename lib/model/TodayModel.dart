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
  final String grand_total_hours_rendered;

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
    required this.time_rendered_am,
    required this.time_rendered_pm,
    required this.total_hours_rendered,
    required this.date,
    required this.grand_total_hours_rendered,
  });

  factory TodayModel.fromJson(Map<String, dynamic> json) {
    return TodayModel(
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
        time_rendered_am: json['time_rendered_am'],
        time_rendered_pm: json['time_rendered_pm'],
        total_hours_rendered: json['total_hours_rendered'],
        date: json['date'],
        grand_total_hours_rendered: json['grand_total_hours_rendered']);
  }
}
