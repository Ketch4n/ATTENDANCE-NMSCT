// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:async';

import 'package:attendance_nmsct/src/auth/google/pin_map.dart';
import 'package:attendance_nmsct/src/controller/Create.dart';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/functions/generate.dart';
import 'package:attendance_nmsct/src/include/style.dart';
import 'package:attendance_nmsct/src/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/src/widgets/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateClassRoom extends StatefulWidget {
  const CreateClassRoom({
    super.key,
    required this.role,
    required this.purpose,
    required this.refreshCallback,
  });
  final String role;

  final String purpose;

  final VoidCallback refreshCallback;
  @override
  State<CreateClassRoom> createState() => _CreateClassRoomState();
}

class _CreateClassRoomState extends State<CreateClassRoom> {
  final code = TextEditingController();
  final location = TextEditingController();
  final longi = TextEditingController();
  final lati = TextEditingController();

  final fulladdress = TextEditingController();
  final hoursController = TextEditingController();
  final radiusController = TextEditingController();

  // StreamSubscription<loc.LocationData>? _positionSubscription;
  bool _show = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.purpose}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You're currently signed as",
                  ),
                  userProfile(),
                  Divider(
                    color: Colors.grey[600],
                  ),
                  Column(
                    children: [
                      !_show
                          ? TextFormField(
                              controller: fulladdress,
                              readOnly: true,
                              decoration: Style.textdesign.copyWith(
                                  hintText: UserSession.location == ""
                                      ? 'Address'
                                      : UserSession.location),
                            )
                          : const SizedBox(),
                      !_show
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: TextFormField(
                                controller: location,
                                decoration: Style.textdesign
                                    .copyWith(labelText: 'Establishment name'),
                              ),
                            )
                          : const SizedBox(),
                      !_show
                          ? TextFormField(
                              controller: hoursController,
                              decoration: Style.textdesign
                                  .copyWith(labelText: 'Total Hours required'),
                            )
                          : const SizedBox(),
                      !_show
                          ? TextFormField(
                              controller: radiusController,
                              decoration: Style.textdesign.copyWith(
                                  labelText: 'Radius (default 5 meters)'),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          'Click to scan location',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
                        ),
                      ),
                      Container(
                        decoration: Style.boxdecor,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: SizedBox(
                              height: 100,
                              width: 100,
                              child: IconButton(
                                color: Colors.redAccent,
                                iconSize: 50,
                                icon: const Icon(Icons.location_pin),
                                onPressed: () async {
                                  final value = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const PinMap()),
                                  );
                                  if (value != null) {
                                    setState(() {
                                      _show = false;
                                    });
                                  }
                                },
                              )),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () async {
                            final String loc = location.text;
                            final String hours = hoursController.text.trim();
                            final String radius = radiusController.text.trim();

                            if (loc.isEmpty || hours.isEmpty) {
                              String title = "Name or Hours Empty !";
                              String message = "Input details";
                              await showAlertDialog(context, title, message);
                            } else {
                              String code = generateAlphanumericId();
                              String currentCoordinate = UserSession.location;
                              double? currentLat = UserSession.latitude;
                              double? currentLng = UserSession.longitude;
                              String radiusMeter =
                                  radius.isEmpty ? "5" : radius;

                              // ignore: use_build_context_synchronously
                              await CreateSectEstab(
                                  context,
                                  // code,
                                  loc,
                                  currentCoordinate,
                                  currentLng!,
                                  currentLat!,
                                  // Session.email,
                                  hours,
                                  radiusMeter);
                              // await pasteCode(context, title, message, code);
                              // String purpose = 'CreateClassRoom';
                              // await CreateSectEstab(context, pin);
                              // await showAlertDialog(context, title, message);
                              Navigator.of(context).pop(false);
                              widget.refreshCallback();
                            }
                          },
                          child: Text(
                            "Save",
                            style: Style.link,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

pasteCode(
    BuildContext context, String title, String message, String code) async {
  showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      });
  await Future.delayed(const Duration(seconds: 1));
  Navigator.of(context).pop(true);
  // Navigator.of(context).popUntil((route) => route.isFirst);
  await showDialog<bool>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: Style.MontserratBold.copyWith(
              color: title == 'Success' || title == 'Login success'
                  ? Colors.green
                  : Colors.orange),
        ),
        content: Text(
          message,
          style: Style.MontserratRegular,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(code),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: code)); // Copies 'code' to clipboard
              Navigator.of(context).pop(false);
              // Show a snackbar or any other indication that the text has been copied
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Text copied: $code')),
              );
            },
          ),
        ],
      );
    },
  );
}
