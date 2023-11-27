import 'package:attendance_nmsct/view/administrator/dashboard/admin/widgets/header.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:flutter/material.dart';

class Admindtr extends StatefulWidget {
  const Admindtr({super.key, required this.name});
  final String name;
  @override
  State<Admindtr> createState() => _AdmindtrState();
}

class _AdmindtrState extends State<Admindtr> {
  bool isLoading = true; // Track if data is loading
  int userId = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        adminHeader(widget.name),
        const SizedBox(height: 20),
        const DropdownSettings(),
        //  Expanded(
        //   child: CardListSkeleton(
        //     isCircularImage: true,
        //     isBottomLinesActive: true,
        //     length: 1,
        //   ),
        // )
      ],
    );
  }
}
