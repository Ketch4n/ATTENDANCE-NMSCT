// import 'package:attendance_nmsct/model/TodayModel.dart';
// import 'package:flutter/material.dart';

// Future<void> showReport(
//     BuildContext context, TodayModel report, String InAM, String InPM) async {
//   return showModalBottomSheet(
//     context: context,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//     ),
//     barrierColor: Colors.black87.withOpacity(0.5),
//     isScrollControlled: true,
//     builder: (context) => DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.32,
//       maxChildSize: 0.5,
//       minChildSize: 0.32,
//       builder: (context, scrollController) => SingleChildScrollView(
//         controller: scrollController,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10.0),
//           child: Column(
//             children: [
//               const SizedBox(
//                 width: 50,
//                 child: Divider(
//                   color: Colors.black26,
//                   thickness: 4,
//                 ),
//               ),
//               _buildListTile(
//                 "Total Hours rendered :",
//                 report.total_hours_rendered,
//                 Colors.blue,
//               ),
//               _buildListTile(
//                 "Time In AM:",
//                 InAM.compareTo(report.sched_in_am) <= 0 ? "On Time" : "Late",
//                 InAM.compareTo(report.sched_in_am) <= 0
//                     ? Colors.green
//                     : Colors.red,
//               ),
//               _buildListTile(
//                 "Time In PM:",
//                 InPM.compareTo(report.sched_in_pm) <= 0 &&
//                         InPM.compareTo('00:00:00') != 0
//                     ? "On Time"
//                     : InPM.compareTo('00:00:00') == 0
//                         ? "Pending"
//                         : "Late",
//                 InPM.compareTo(report.sched_in_pm) <= 0 &&
//                         InPM.compareTo('00:00:00') != 0
//                     ? Colors.green
//                     : InPM.compareTo('00:00:00') == 0
//                         ? Colors.blue
//                         : Colors.red,
//               ),
//               _buildListTile(
//                 "Undertime:",
//                 report.total_undertime,
//                 Colors.orange,
//               ),
//               _buildListTile(
//                 "Overtime:",
//                 report.total_overtime,
//                 Colors.purple,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildListTile(
//     String leadingText, String trailingText, Color trailingColor) {
//   return ListTile(
//     leading: Text(
//       leadingText,
//       style: TextStyle(color: Colors.black, fontSize: 20),
//     ),
//     trailing: Text(
//       trailingText,
//       style: TextStyle(color: trailingColor, fontSize: 20),
//     ),
//   );
// }
