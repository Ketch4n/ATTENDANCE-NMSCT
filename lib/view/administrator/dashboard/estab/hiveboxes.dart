import 'package:hive/hive.dart';

class HiveBoxes {
  static Box lateBox = Hive.box('lateBox');
  static Box countEstabBox = Hive.box('countEstabBox');
  static Box absentBox = Hive.box('absentBox');
  static Box outsideBox = Hive.box('outsideBox');
  static Box announcementBox = Hive.box('announcementBox');
  static Box outsideIdsBox = Hive.box('outsideIdsBox');
}
