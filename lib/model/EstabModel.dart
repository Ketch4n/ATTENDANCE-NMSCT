class EstabModel {
  final String id;
  final String code;
  final String establishment_name;
  final String creator_email;
  final String location;
  final String longitude;
  final String latitude;
  final String status;

  EstabModel({
    required this.id,
    required this.code,
    required this.establishment_name,
    required this.creator_email,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'code': code,
        'establishment_name': establishment_name,
        'creator_email': creator_email,
        'location': location,
        'longitude': longitude,
        'latitude': latitude,
        'status': status,
      };

  static EstabModel fromJson(Map<String, dynamic> json) => EstabModel(
        // id: json['id'],
        id: json['id'],
        code: json['code'],
        establishment_name: json['establishment_name'],
        creator_email: json['creator_email'],
        location: json['location'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        status: json['status'],
      );
}
