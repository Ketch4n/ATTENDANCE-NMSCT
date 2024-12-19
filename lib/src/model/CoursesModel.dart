class CoursesModel {
  final String id;
  final String courses;
  final String count;

  CoursesModel({required this.id, required this.courses, required this.count});

  // Factory method to create a CoursesModel from a JSON map
  factory CoursesModel.fromJson(Map<String, dynamic> json) {
    return CoursesModel(
      id: json['id'],
      courses: json['courses'],
      count: json['count'],
    );
  }

  // Method to convert a CoursesModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courses': courses,
      'count': count,
    };
  }
}
