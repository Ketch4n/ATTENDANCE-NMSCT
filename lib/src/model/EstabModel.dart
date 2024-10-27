class EstabModel {
  final int id;
  // final String code;
  final String establishment_name;
  // final String creator_email;
  final String location;
  final String longitude;
  final String latitude;
  final String hours_required;
  final String status;

  EstabModel({
    required this.id,
    // required this.code,
    required this.establishment_name,
    // required this.creator_email,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.hours_required,
    required this.status,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        // 'code': code,
        'establishment_name': establishment_name,
        // 'creator_email': creator_email,
        'location': location,
        'longitude': longitude,
        'latitude': latitude,
        'hours_required': hours_required,
        'status': status,
      };

  // Create model from JSON
  static EstabModel fromJson(Map<String, dynamic> json) => EstabModel(
        id: json['id'],
        // code: json['code'],
        establishment_name: json['establishment_name'],
        // creator_email: json['creator_email'],
        location: json['location'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        hours_required: json['hours_required'],
        status: json['status'],
      );
}
