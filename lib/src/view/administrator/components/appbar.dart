import 'package:attendance_nmsct/src/data/index/page_title_value.dart';
import 'package:flutter/material.dart';

AppBar homeAppBar(int currentIndex) => AppBar(
      centerTitle: true,
      backgroundColor: Colors.blue,
      title: Text(
        pageTitleValue(currentIndex),
        style: const TextStyle(color: Colors.white),
      ),
    );
