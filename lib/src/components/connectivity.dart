import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  late StreamSubscription<ConnectivityResult> _connectionSubscription;

  ConnectivityProvider() {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _connectionSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _isOffline = (result == ConnectivityResult.none);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }
}
