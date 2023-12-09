class UserModel {
  final String id;
  final String email;
  final String name;
  final String user_id;
  final String role;
  final String section_id;
  final String section_name;
  final String admin_id;
  final String establishment_id;
  final String establishment_name;
  final String location;
  final String longitude;
  final String latitude;
  final String creator_id;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      required this.user_id,
      required this.role,
      required this.section_id,
      required this.section_name,
      required this.admin_id,
      required this.establishment_id,
      required this.establishment_name,
      required this.location,
      required this.longitude,
      required this.latitude,
      required this.creator_id});

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'name': name,
        'user_id': user_id,
        'role': role,
        'section_id': section_id,
        'section_name': section_name,
        'admin_id': admin_id,
        'establishment_id': establishment_id,
        'establishment_name': establishment_name,
        'location': location,
        'longitude': longitude,
        'latitude': latitude,
        'creator_id': creator_id
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
      // id: json['id'],
      id: json['id'],
      email: json['email'],
      name: json['name'],
      user_id: json['user_id'],
      role: json['role'],
      section_id: json['section_id'],
      section_name: json['section_name'],
      admin_id: json['admin_id'],
      establishment_id: json['establishment_id'],
      establishment_name: json['establishment_name'],
      location: json['location'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      creator_id: json['creator_id']);
}
