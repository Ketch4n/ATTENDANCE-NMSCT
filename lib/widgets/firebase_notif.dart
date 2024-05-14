import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreate(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplay(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onNotificationRecieved(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onNotificationClick(
      ReceivedNotification receivedNotification) async {}
}

// import 'package:firebase_messaging/firebase_messaging.dart';

// class FirebaseNOTIFICATIONapi {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   Future<void> isNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fCMToken = await _firebaseMessaging.getToken();
//     print('Token: $fCMToken');
//   }
// }
