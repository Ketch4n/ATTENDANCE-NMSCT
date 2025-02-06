class TodayModel {
  final String id;
  final String student_id;
  final String estab_id;
  final String time_in_am;
  final String in_am_lat;
  final String in_am_long;
  final String time_out_am;
  final String out_am_lat;
  final String out_am_long;
  final String time_in_pm;
  final String in_pm_lat;
  final String in_pm_long;
  final String time_out_pm;
  final String out_pm_lat;
  final String out_pm_long;
  final String date;
  final String sched_in_am;
  final String sched_out_am;
  final String sched_in_pm;
  final String sched_out_pm;
  final String time_rendered_am;
  final String time_rendered_pm;
  final String undertime_am;
  final String undertime_pm;
  final String total_undertime;
  final String overtime_am;
  final String overtime_pm;
  final String total_overtime;
  final String total_hours_rendered;
  final String hours;
  final String minutes;
  final String grand_total_hours_rendered;
  final String grand_total_undertime;
  final String grand_total_overtime;

  TodayModel({
    required this.id,
    required this.student_id,
    required this.estab_id,
    required this.time_in_am,
    required this.in_am_lat,
    required this.in_am_long,
    required this.time_out_am,
    required this.out_am_lat,
    required this.out_am_long,
    required this.time_in_pm,
    required this.in_pm_lat,
    required this.in_pm_long,
    required this.time_out_pm,
    required this.out_pm_lat,
    required this.out_pm_long,
    required this.date,
    required this.sched_in_am,
    required this.sched_out_am,
    required this.sched_in_pm,
    required this.sched_out_pm,
    required this.time_rendered_am,
    required this.time_rendered_pm,
    required this.undertime_am,
    required this.undertime_pm,
    required this.total_undertime,
    required this.overtime_am,
    required this.overtime_pm,
    required this.total_overtime,
    required this.total_hours_rendered,
    required this.hours,
    required this.minutes,
    required this.grand_total_hours_rendered,
    required this.grand_total_undertime,
    required this.grand_total_overtime,
  });

  factory TodayModel.fromJson(Map<String, dynamic> json) {
    return TodayModel(
      id: json['id'],
      student_id: json['student_id'],
      estab_id: json['estab_id'],
      time_in_am: json['time_in_am'],
      in_am_lat: json['in_am_lat'],
      in_am_long: json['in_am_long'],
      time_out_am: json['time_out_am'],
      out_am_lat: json['out_am_lat'],
      out_am_long: json['out_am_long'],
      time_in_pm: json['time_in_pm'],
      in_pm_lat: json['in_pm_lat'],
      in_pm_long: json['in_pm_long'],
      time_out_pm: json['time_out_pm'],
      out_pm_lat: json['out_pm_lat'],
      out_pm_long: json['out_pm_long'],
      date: json['date'],
      sched_in_am: json['sched_in_am'],
      sched_out_am: json['sched_out_am'],
      sched_in_pm: json['sched_in_pm'],
      sched_out_pm: json['sched_out_pm'],
      time_rendered_am: json['time_rendered_am'],
      time_rendered_pm: json['time_rendered_pm'],
      undertime_am: json['undertime_am'],
      undertime_pm: json['undertime_pm'],
      total_undertime: json['total_undertime'],
      overtime_am: json['overtime_am'],
      overtime_pm: json['overtime_pm'],
      total_overtime: json['total_overtime'],
      total_hours_rendered: json['total_hours_rendered'],
      hours: json['hours'],
      minutes: json['minutes'],
      grand_total_hours_rendered: json['grand_total_hours_rendered'],
      grand_total_undertime: json['grand_total_undertime'],
      grand_total_overtime: json['grand_total_overtime'],
    );
  }
}
