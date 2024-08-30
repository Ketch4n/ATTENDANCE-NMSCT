import 'dart:async';
import 'package:attendance_nmsct/include/navbar.dart';
import 'package:attendance_nmsct/widgets/duck.dart';
import 'package:attendance_nmsct/widgets/offline_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class StudentIndex extends StatefulWidget {
  const StudentIndex({super.key});

  @override
  State<StudentIndex> createState() => _StudentIndexState();
}

class _StudentIndexState extends State<StudentIndex> {
  StreamSubscription? internetconnection;
  bool isoffline = false;
  int _currentIndex = 0;

  void _onMenuItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    internetconnection!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(onMenuItemTap: _onMenuItemTap),
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "Dashboard" : "Profile"),
        centerTitle: true,
      ),
      bottomNavigationBar: isoffline
          ? SizedBox(
              height: 80,
              child: Expanded(
                child: BottomAppBar(
                  elevation: 0,
                  child: Center(
                    child:
                        offlineSnackbar("You are currently Offline", isoffline),
                  ),
                ),
              ),
            )
          : const SizedBox(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Duck(),
          Duck(),
        ],
      ),
      // use SizedBox to contrain the AppMenu to a fixed width
    );
  }
}
