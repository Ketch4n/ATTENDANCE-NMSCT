class EstabRoomModel {
  final String id;
  final String fname;
  final String lname;
  final String email;

  EstabRoomModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'id': id,
        'fname': fname,
        'lname': lname,
        'email': email,
      };

  static EstabRoomModel fromJson(Map<String, dynamic> json) => EstabRoomModel(
        // id: json['id'],
        id: json['id'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
      );
}
