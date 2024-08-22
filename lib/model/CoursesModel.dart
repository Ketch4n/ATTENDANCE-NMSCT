class CoursesModel {
  // final String id;
  final String course;
  final String count;

  CoursesModel({required this.course, required this.count});

  // Factory method to create a CoursesModel from a JSON map
  factory CoursesModel.fromJson(Map<String, dynamic> json) {
    return CoursesModel(
      // id: json['id'],
      course: json['course'],
      count: json['count'],
    );
  }

  // Method to convert a CoursesModel to JSON
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'course': course,
      'count': count,
    };
  }
}
