import 'package:attendance_nmsct/view/student/dashboard/section/absent_record.dart';
import 'package:attendance_nmsct/view/student/dashboard/section/absent_pending.dart';
import 'package:flutter/material.dart';

class AbsentTab extends StatefulWidget {
  const AbsentTab({super.key, required this.name, required this.ids});
  final String name;
  final String ids;
  @override
  State<AbsentTab> createState() => _AbsentTabState();
}

class _AbsentTabState extends State<AbsentTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Pending'), Tab(text: 'Records')],
            ),
            const SizedBox(
              height: 10,
            ),
            // Text(
            //     "${DateFormat('MMM dd, yyyy').format(DateTime.now())} - TODAY"),
            Expanded(
              child: TabBarView(
                children: [
                  AbsentPendingTab(ids: widget.ids, name: widget.name),
                  AbsentRecordTab(ids: widget.ids, name: widget.name),
                  // MetaDataIndex(ids: widget.ids, name: widget.name),
                  // AccomplishmentView(ids: widget.ids, name: widget.name)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
