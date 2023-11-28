class AccomplishmentTodayModel {
  final String email;

  final String date;
  final String max_time;

  AccomplishmentTodayModel(
      {required this.email, required this.date, required this.max_time});

  Map<String, dynamic> toJson() => {
        // 'id': id,

        'email': email,

        'date': date,
        'max_time': max_time,
      };

  static AccomplishmentTodayModel fromJson(Map<String, dynamic> json) =>
      AccomplishmentTodayModel(
        // id: json['id'],

        email: json['email'],

        date: json['date'],
        max_time: json['max_time'],
      );
}
