class UserModel {
  final String id;
  final String email;
  final String fname;
  final String lname;
  final String role;
  // final String section_id;
  // final String section_name;
  // final String admin_id;
  final String establishment_id;
  final String establishment_name;
  final String location;
  final String longitude;
  final String latitude;
  final String radius;
  final String creator_email;
  final String hours_required;

  UserModel({
    required this.id,
    required this.email,
    required this.fname,
    required this.lname,
    required this.role,
    // required this.section_id,
    // required this.section_name,
    // required this.admin_id,
    required this.establishment_id,
    required this.establishment_name,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.radius,
    required this.creator_email,
    required this.hours_required,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'email': email,
        'fname': fname,
        'lname': lname,
        'role': role,
        // 'section_id': section_id,
        // 'section_name': section_name,
        // 'admin_id': admin_id,
        'establishment_id': establishment_id,
        'establishment_name': establishment_name,
        'location': location,
        'longitude': longitude,
        'latitude': latitude,
        'radius': radius,
        'creator_email': creator_email,
        'hours_required': hours_required,
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        // id: json['id'],
        id: json['id'],
        email: json['email'],
        fname: json['fname'],
        lname: json['lname'],
        role: json['role'],
        // section_id: json['section_id'],
        // section_name: json['section_name'],
        // admin_id: json['admin_id'],
        establishment_id: json['establishment_id'],
        establishment_name: json['establishment_name'],
        location: json['location'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        radius: json['radius'],
        creator_email: json['creator_email'],
        hours_required: json['hours_required'],
      );
}
