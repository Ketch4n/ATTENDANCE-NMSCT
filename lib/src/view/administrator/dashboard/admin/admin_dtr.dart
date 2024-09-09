import 'package:attendance_nmsct/src/view/administrator/dashboard/admin/accomplishment/index.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/admin/metadata/index.dart';
import 'package:attendance_nmsct/src/view/administrator/dashboard/admin/widgets/header.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Admindtr extends StatefulWidget {
  const Admindtr({super.key, required this.ids, required this.name});
  final String ids;
  final String name;
  @override
  State<Admindtr> createState() => _AdmindtrState();
}

class _AdmindtrState extends State<Admindtr> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            adminHeader(widget.name),
            Text(
                "Submitted - TODAY${DateFormat(' MM/dd/yy').format(DateTime.now())}"),
            const SizedBox(
              height: 10,
            ),
            const TabBar(
              tabs: [Tab(text: 'MetaData'), Tab(text: 'Accomplishment')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AdminMetaDataIndex(name: widget.name),
                  AdminAccomplishmentIndex(id: widget.ids)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
