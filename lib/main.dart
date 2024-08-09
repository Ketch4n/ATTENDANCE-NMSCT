import 'package:attendance_nmsct/auth/auth.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/face_recognition/locator.dart';
import 'package:attendance_nmsct/widgets/scroll.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await AwesomeNotifications().initialize(null, [
  //   NotificationChannel(
  //       channelKey: "Flutter_Key",
  //       channelName: "Flutter Notification",
  //       channelDescription: "Flutter Description")
  // ], channelGroups: [
  //   NotificationChannelGroup(
  //       channelGroupKey: "Flutter_Key", channelGroupName: "Flutter Group")
  // ]);
  // bool isAllowedNotification =
  //     await AwesomeNotifications().isNotificationAllowed();
  // if (!isAllowedNotification) {
  //   AwesomeNotifications().requestPermissionToSendNotifications();
  // }

  await Firebase.initializeApp(
      // name: "attendance-monitoring",
      options: const FirebaseOptions(
    apiKey: "AIzaSyCatnsTU-2hveFqSVuU-wu04xya0r_PwAE",
    authDomain: "attendance-monitoring-c33b5.firebaseapp.com",
    projectId: "attendance-monitoring-c33b5",
    databaseURL:
        'https://attendance-monitoring-c33b5-default-rtdb.firebaseio.com/',
    storageBucket: "attendance-monitoring-c33b5.appspot.com",
    messagingSenderId: "923340212066",
    appId: "1:923340212066:web:cfa048f322dbd305098e3b",
  ));
  Server.fetchHostFromDatabase();
  Server.fetchLinkFromDatabase();
  // await FirebaseNOTIFICATIONapi().isNotifications();
  // await getServer();
  await Hive.initFlutter();
  await Hive.openBox('cacheBox');
  setupServices();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRole>(
          create: (_) => UserRole(),
        ),
        ChangeNotifierProvider<HoursRendered>(
          create: (_) => HoursRendered(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // bool isWin = Theme.of(context).platform == TargetPlatform.windows;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance NMSCT',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        scrollbarTheme: Style.scrollbarTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: isWin ? const AdminIndex() : const Auth(),
      home: const Auth(),
      // routes: {
      //   '/view/map': (context) => ViewMap(),
      // },

      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
      // home: const Login(),
    );
  }
}
