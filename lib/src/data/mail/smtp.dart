import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmailNotification(
  String purpose,
  String status,
  String userEmail,
) async {
  final smtpServer =
      gmail('nmscst.attendance@gmail.com', 'zixq rezk uasj ewsv');

  final message = Message()
    ..from = const Address('nmsct.attendance.monitoring@gmail.com', 'NMSCST')
    ..recipients.add(userEmail)
    ..subject = purpose == "Absent" ? 'Absent $status' : "None"
    ..text = purpose == "Absent" ? "Your absent request is $status " : 'None';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: $sendReport');
  } catch (e) {
    print('Error sending email: $e');
  }
}
