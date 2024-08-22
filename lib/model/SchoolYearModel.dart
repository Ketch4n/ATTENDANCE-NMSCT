class SchoolYearModel {
  // final String id;
  final String school_year;
  final String count;

  SchoolYearModel({required this.school_year, required this.count});

  // Factory method to create a SchoolYearModel from a JSON map
  factory SchoolYearModel.fromJson(Map<String, dynamic> json) {
    return SchoolYearModel(
      // id: json['id'],
      school_year: json['school_year'],
      count: json['count'],
    );
  }

  // Method to convert a SchoolYearModel to JSON
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'school_year': school_year,
      'count': count,
    };
  }
}
