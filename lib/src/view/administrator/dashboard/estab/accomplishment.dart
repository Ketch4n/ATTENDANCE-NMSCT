// import 'dart:async';
// import 'dart:convert';

// import 'package:attendance_nmsct/src/data/firebase/server.dart';
// import 'package:attendance_nmsct/src/data/provider/session.dart';
// import 'package:attendance_nmsct/src/include/style.dart';
// import 'package:attendance_nmsct/src/model/AccomplishmentModel.dart';
// import 'package:attendance_nmsct/src/view/student/dashboard/section/metadata/metadata.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class AccomplishmentDetails extends StatefulWidget {
//   const AccomplishmentDetails(
//       {super.key,
//       required this.ids,
//       required this.name,
//       required this.section});
//   final String ids;
//   final String name;

//   final String section;
//   @override
//   State<AccomplishmentDetails> createState() => _AccomplishmentDetailsState();
// }

// class _AccomplishmentDetailsState extends State<AccomplishmentDetails> {
//   bool isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     _getTextReferences();
//   }

//   @override
//   dispose() {
//     super.dispose();

//     _textStreamController.close();
//   }

//   final StreamController<List<AccomplishmentModel>> _textStreamController =
//       StreamController<List<AccomplishmentModel>>();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();
//   Future<void> _getTextReferences() async {
//     try {
//       final response = await http.post(
//         Uri.parse('${Server.host}users/student/accomplishment.php'),
//         body: {
//           'email': Session.email,
//           'section_id': widget.ids,
//           'date': widget.date
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         final List<AccomplishmentModel> text = data
//             .map((textData) => AccomplishmentModel.fromJson(textData))
//             .toList();

//         // Add the list to the stream
//         _textStreamController.add(text);
//       } else {
//         // Handle HTTP error
//         print('Failed to load data. HTTP status code: ${response.statusCode}');
//         // You might want to display an error message to the user
//       }
//     } catch (e) {
//       // Handle other exceptions
//       print('Error: $e');
//       // You might want to display an error message to the user
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<List<AccomplishmentModel>>(
//         stream: _textStreamController.stream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No accomplishments found.'));
//           } else {
//             final accomplishments = snapshot.data!;

//             return RefreshIndicator(
//               onRefresh: _getTextReferences,
//               child: ListView.builder(
//                 itemCount: accomplishments.length,
//                 itemBuilder: (context, index) {
//                   final accomplishment = accomplishments[index];

//                   return Card(
//                     margin: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 15),
//                     elevation: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.all(15),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             accomplishment.email,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'Date: ${accomplishment.date}',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'Section: ${widget.section}',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
