class EstabRoomModel {
  final int id;
  final int uid;
  final String fname;
  final String lname;
  final String email;
  final int? sched_id;
  final int? estab_id;
  final String? in_am;
  final String? out_am;
  final String? in_pm;
  final String? out_pm;

  EstabRoomModel({
    required this.id,
    required this.uid,
    required this.fname,
    required this.lname,
    required this.email,
    this.estab_id,
    this.in_am,
    this.in_pm,
    this.out_am,
    this.out_pm,
    this.sched_id,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'uid': uid,
        'fname': fname,
        'lname': lname,
        'email': email,
        'sched_id': sched_id,
        'estab_id': estab_id,
        'in_am': in_am,
        'out_am': out_am,
        'in_pm': in_pm,
        'out_pm': out_pm,
      };

  static EstabRoomModel fromJson(Map<String, dynamic> json) => EstabRoomModel(
        // id: json['id'],
        id: json['id'],
        uid: json['uid'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        sched_id: json['sched_id'],
        estab_id: json['estab_id'],
        in_am: json['in_am'],
        out_am: json['out_am'],
        in_pm: json['in_pm'],
        out_pm: json['out_pm'],
      );
}
