class EstabTodayModel {
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
  final String? lname;
  final String? email;
  final String? latitude;
  final String? longitude;

  EstabTodayModel({
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
    this.lname,
    this.email,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'student_id': student_id,
        'estab_id': estab_id,
        'time_in_am': time_in_am,
        'in_am_lat': in_am_lat,
        'in_am_long': in_am_long,

        'time_out_am': time_out_am,
        'out_am_lat': out_am_lat,
        'out_am_long': out_am_long,

        'time_in_pm': time_in_pm,
        'in_pm_lat': in_pm_lat,
        'in_pm_long': in_pm_long,

        'time_out_pm': time_out_pm,
        'out_pm_lat': out_pm_lat,
        'out_pm_long': out_pm_long,
        'date': date,
        'lname': lname,
        'email': email,
        'latitude': latitude,
        'longitude': longitude,
      };

  static EstabTodayModel fromJson(Map<String, dynamic> json) => EstabTodayModel(
        // id: json['id'],
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
        lname: json['lname'],
        email: json['email'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}
