import 'package:hive_flutter/adapters.dart';

class ApiCache {
  static final _box = Hive.box('cacheBox');

  static Future<void> cacheData(String key, dynamic data) async {
    await _box.put(key, data);
  }

  static dynamic getCachedData(String key) {
    return _box.get(key);
  }
}
