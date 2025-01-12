import 'package:flutter/material.dart';

Widget offlineSnackbar(bool isOffline) => isOffline
    ? const SizedBox(
        height: 80,
        child: BottomAppBar(
          elevation: 0,
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "You are currently Offline",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      )
    : const SizedBox();
