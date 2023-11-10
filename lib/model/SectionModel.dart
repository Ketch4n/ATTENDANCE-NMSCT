class SectionModel {
  final String id;
  final String code;
  final String section_name;
  final String admin_id;
  final String status;

  SectionModel({
    required this.id,
    required this.code,
    required this.section_name,
    required this.admin_id,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'code': code,
        'section_name': section_name,
        'admin_id': admin_id,
        'status': status,
      };

  static SectionModel fromJson(Map<String, dynamic> json) => SectionModel(
        // id: json['id'],
        id: json['id'],
        code: json['code'],
        section_name: json['section_name'],
        admin_id: json['admin_id'],
        status: json['status'],
      );
}
