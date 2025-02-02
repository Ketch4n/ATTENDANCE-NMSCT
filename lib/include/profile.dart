import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/dropdown_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalProfile extends StatefulWidget {
  const GlobalProfile({super.key});

  @override
  State<GlobalProfile> createState() => _GlobalProfileState();
}

class _GlobalProfileState extends State<GlobalProfile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                kIsWeb
                    ? const SizedBox()
                    : Image.asset("assets/images/laptop.jpg"),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: kIsWeb
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/images/admin.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                          // )
                        ),
                      ),
                      Column(
                        crossAxisAlignment: kIsWeb
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            Session.fname,
                            style: Style.profileText.copyWith(fontSize: 18),
                          ),
                          Text(
                            Session.email,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const DropdownSettings(),
          ],
        ),
      ),
    );
  }
}

// Future showGlobalProfileEdit(BuildContext context) async {
//   showAdaptiveActionSheet(
//     context: context,
//     title: const Text('Edit Profile Photo'),
//     androidBorderRadius: 20,
//     actions: <BottomSheetAction>[
//       BottomSheetAction(
//           title: const Text(
//             'Edit Details',
//             style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.black,
//                 fontFamily: "MontserratBold"),
//           ),
//           onPressed: (context) {
//             Navigator.of(context).pop(false);
//           }),
//       BottomSheetAction(
//           title: const Text(
//             'Change Profile',
//             style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.black,
//                 fontFamily: "MontserratBold"),
//           ),
//           onPressed: (context) {
//             Navigator.of(context).pop(false);
//           }),
//     ],
//   );
// }
