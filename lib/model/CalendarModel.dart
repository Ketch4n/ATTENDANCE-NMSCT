class UserAttendance {
  final String email;
  final String lname;
  final String timeInAM;
  final String timeOutAM;
  final String timeInPM;
  final String timeOutPM;
  final String date;

  UserAttendance({
    required this.email,
    required this.lname,
    required this.timeInAM,
    required this.timeOutAM,
    required this.timeInPM,
    required this.timeOutPM,
    required this.date,
  });

  factory UserAttendance.fromJson(Map<String, dynamic> json) {
    return UserAttendance(
      email: json['email'],
      lname: json['lname'],
      timeInAM: json['time_in_am'],
      timeOutAM: json['time_out_am'],
      timeInPM: json['time_in_pm'],
      timeOutPM: json['time_out_pm'],
      date: json['date'],
    );
  }
}
