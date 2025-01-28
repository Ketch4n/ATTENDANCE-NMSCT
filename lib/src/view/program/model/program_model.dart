class ProgramModel {
  final int id;
  final String courses;
  final String abbr;

  ProgramModel({
    required this.id,
    required this.courses,
    required this.abbr,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      courses: json['courses'],
      abbr: json['abbr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courses': courses,
      'abbr': abbr,
    };
  }
}
