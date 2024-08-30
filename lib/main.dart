import 'package:attendance_nmsct/auth/auth.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/data/settings.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/face_recognition/locator.dart';
import 'package:attendance_nmsct/src/firebase/initialize.dart';
import 'package:attendance_nmsct/widgets/scroll.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  Server.fetchHostFromDatabase();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance NMSCT',
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        scrollbarTheme: Style.scrollbarTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Auth(),
    );
  }
}
