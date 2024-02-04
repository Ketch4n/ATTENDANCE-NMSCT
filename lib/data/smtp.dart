import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmailNotification(String purpose, String userEmail) async {
  final smtpServer =
      gmail('sabungan.katemaberly366@gmail.com', 'vcxqnvmdzkwgqibs');

  final message = Message()
    ..from = Address('sabungan.katemaberly366@gmail.com', 'Flutter')
    ..recipients.add(userEmail)
    ..subject = purpose == "login"
        ? 'Welcome Back Visitor'
        : "Welcome to Cemetery Record Information!"
    ..text = purpose == "signup"
        ? "Greetings! Your account with Cemetery Record has been successfully created. You are now part of our community to manage cemetery records. Feel free to explore and update information as needed"
        : 'Welcome back! Your login to Cemetery Record Information System was successful. If you have any updates or inquiries regarding cemetery records, please proceed with confidence';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } catch (e) {
    print('Error sending email: $e');
  }
}
