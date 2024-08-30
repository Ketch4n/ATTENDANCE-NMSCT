// import 'package:attendance_nmsct/controller/Login.dart';
// import 'package:attendance_nmsct/data/settings.dart';
// import 'package:attendance_nmsct/include/style.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {


//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Consumer<UserRole>(builder: (context, user, child) {
//       return GestureDetector(
//         onTap: () {
//           FocusScopeNode currentFocus = FocusScope.of(context);
//           if (!currentFocus.hasPrimaryFocus &&
//               currentFocus.focusedChild != null) {
//             currentFocus.unfocus();
//           }
//         },
//         child: Scaffold(
//           body: 
//         ),
//       );
//     });
//   }
// }
