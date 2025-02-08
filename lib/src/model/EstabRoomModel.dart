class EstabRoomModel {
  final int id;
  final int student_id;
  final int establishment_id;
  final String fname;
  final String lname;
  final String email;
  final int? sched_id;
  final int? estab_id;
  final String? in_am;
  final String? out_am;
  final String? in_pm;
  final String? out_pm;
  final String? dateFrom;
  final String? dateTo;

  EstabRoomModel({
    required this.id,
    required this.student_id,
    required this.establishment_id,
    required this.fname,
    required this.lname,
    required this.email,
    this.estab_id,
    this.in_am,
    this.in_pm,
    this.out_am,
    this.out_pm,
    this.sched_id,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'student_id': student_id,
        'establishment_id': establishment_id,
        'fname': fname,
        'lname': lname,
        'email': email,
        'sched_id': sched_id,
        'estab_id': estab_id,
        'in_am': in_am,
        'out_am': out_am,
        'in_pm': in_pm,
        'out_pm': out_pm,
        'date_from': dateFrom,
        'date_to': dateTo,
      };

  static EstabRoomModel fromJson(Map<String, dynamic> json) => EstabRoomModel(
        // id: json['id'],
        id: json['id'],
        student_id: json['student_id'],
        establishment_id: json['establishment_id'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        sched_id: json['sched_id'],
        estab_id: json['estab_id'],
        in_am: json['in_am'],
        out_am: json['out_am'],
        in_pm: json['in_pm'],
        out_pm: json['out_pm'],
        dateFrom: json['date_from'],
        dateTo: json['date_to'],
      );
}
