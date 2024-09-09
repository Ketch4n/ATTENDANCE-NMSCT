// import 'package:attendance_nmsct/controller/Upload.dart';
// import 'package:attendance_nmsct/data/session.dart';
// import 'package:attendance_nmsct/view/student/dashboard/establishment/widgets/record_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// // bool isKeyboard = false;
// DateTime now = DateTime.now();
// // final date = DateFormat('MM-dd-yyyy').format(now.toLocal());
// Future accomplishmentRecord(BuildContext context, folder, name) async {
//   return showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
//       barrierColor: Colors.black87.withOpacity(0.5),
//       isScrollControlled: true,
//       builder: (context) => GestureDetector(
//             onTap: () {
//               FocusScopeNode currentFocus = FocusScope.of(context);
//               if (!currentFocus.hasPrimaryFocus &&
//                   currentFocus.focusedChild != null) {
//                 currentFocus.unfocus();
//                 // isKeyboard = false;
//               }
//             },
//             child: DraggableScrollableSheet(
//               expand: false,
//               initialChildSize: 0.5, // Half of the screen height
//               minChildSize: 1 / 3, // 1/3 of the screen height
//               maxChildSize: 0.8, // Almost cover the screen height
//               builder: (context, scrollController) => SingleChildScrollView(
//                 controller: scrollController,
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       width: 50,
//                       child: Divider(
//                         color: Colors.black26,
//                         thickness: 4,
//                       ),
//                     ),
//                     ListTile(
//                       leadingAndTrailingTextStyle:
//                           const TextStyle(fontSize: 20, color: Colors.black),
//                       leading: const Text(
//                         "Record :",
//                       ),
//                       trailing: Text(folder),
//                     ),
//                     SizedBox(),
//                   ],
//                 ),
//               ),
//             ),
//           ));
// }
