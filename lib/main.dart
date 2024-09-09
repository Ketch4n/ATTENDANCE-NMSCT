import 'package:attendance_nmsct/src/auth/auth.dart';
import 'package:attendance_nmsct/src/data/firebase/server.dart';
import 'package:attendance_nmsct/src/data/provider/settings.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/data/firebase/initialize.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  Server.fetchHostFromDatabase();
  Server.fetchLinkFromDatabase();
  await Hive.initFlutter();
  await Hive.openBox('cacheBox');

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
      scrollBehavior: MyCustomScrollBehavior(),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
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

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
