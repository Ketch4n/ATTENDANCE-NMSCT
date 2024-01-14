import 'dart:convert';

class User {
  String user;
  String password;
  List<dynamic> modelData;

  User({
    required this.user,
    required this.password,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      user: user['user'],
      password: user['password'],
      modelData: List<dynamic>.from(jsonDecode(user['model_data'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'password': password,
      'model_data': jsonEncode(modelData),
    };
  }
}
