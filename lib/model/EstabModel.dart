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
  final int? sched_id;
  final int? estab_id;
  final String? in_am;
  final String? out_am;
  final String? in_pm;
  final String? out_pm;

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
    this.estab_id,
    this.in_am,
    this.in_pm,
    this.out_am,
    this.out_pm,
    this.sched_id,
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
        'sched_id': sched_id,
        'estab_id': estab_id,
        'in_am': in_am,
        'out_am': out_am,
        'in_pm': in_pm,
        'out_pm': out_pm,
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
        sched_id: json['sched_id'],
        estab_id: json['estab_id'],
        in_am: json['in_am'],
        out_am: json['out_am'],
        in_pm: json['in_pm'],
        out_pm: json['out_pm'],
      );
}
