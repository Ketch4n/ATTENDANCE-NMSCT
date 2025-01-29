class SchoolYearModel {
  final int id;
  final String year;

  SchoolYearModel({required this.id, required this.year});

  factory SchoolYearModel.fromJson(Map<String, dynamic> json) {
    return SchoolYearModel(
      id: json['id'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
    };
  }
}

List<SchoolYearModel> parseSchoolYearModels(List<dynamic> response) {
  return response.map((json) => SchoolYearModel.fromJson(json)).toList();
}
