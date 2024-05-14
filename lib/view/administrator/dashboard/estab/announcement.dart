import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/widget/dialog.dart';
import 'package:flutter/material.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key});

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [Text("data")],
        ));
  }
}
