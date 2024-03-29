import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmailNotification(
    String purpose, String status, String userEmail, String custom) async {
  final smtpServer =
      gmail('nmsct.attendance.monitoring@gmail.com', 'krid xglq luum xmkt');

  final message = Message()
    ..from = Address('nmsct.attendance.monitoring@gmail.com', '$custom')
    ..recipients.add(userEmail)
    ..subject = purpose == "Absent" ? 'Absent $status' : "None"
    ..text = purpose == "Absent" ? "Your absent request is $status " : 'None';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } catch (e) {
    print('Error sending email: $e');
  }
}
