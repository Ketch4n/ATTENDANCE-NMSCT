class EstabModel {
  final String id;
  final String code;
  final String establishment_name;
  final String creator_id;
  final String location;
  final String status;

  EstabModel({
    required this.id,
    required this.code,
    required this.establishment_name,
    required this.creator_id,
    required this.location,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'code': code,
        'establishment_name': establishment_name,
        'creator_id': creator_id,
        'location': location,
        'status': status,
      };

  static EstabModel fromJson(Map<String, dynamic> json) => EstabModel(
        // id: json['id'],
        id: json['id'],
        code: json['code'],
        establishment_name: json['establishment_name'],
        creator_id: json['creator_id'],
        location: json['location'],
        status: json['status'],
      );
}
