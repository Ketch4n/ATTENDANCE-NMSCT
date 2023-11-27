// // ignore_for_file: use_build_context_synchronously

// import 'package:attendance_nmsct/controller/Delete.dart';
// import 'package:attendance_nmsct/include/style.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // Import SharedPreferences

// Future confirm(BuildContext context, purpose, id, VoidCallback refresh) async {
//   showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return CupertinoAlertDialog(
//         title: Text(
//           purpose == 'Delete' ? "Confirm Delete ?" : "Confirm Remove ?",
//           style: Style.MontserratBold,
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('No'),
//             onPressed: () {
//               Navigator.of(context).pop(false);
//             },
//           ),
//           TextButton(
//             child: const Text('Yes'),
//             onPressed: () async {
//               Navigator.of(context).pop(false);
//               await deleteAccomplishment(context, id, refresh);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
