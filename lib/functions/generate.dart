import 'dart:math';

String generateId() {
  var random = Random();
  return random.nextInt(999999999).toString();
}

String generateAlphanumericId() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  const idLength = 8; // You can adjust the length as needed

  return String.fromCharCodes(Iterable.generate(
    idLength,
    (_) => chars.codeUnitAt(random.nextInt(chars.length)),
  ));
}

String getRandomString(int length) {
  const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (_) => charset[Random().nextInt(charset.length)])
      .join();
}
