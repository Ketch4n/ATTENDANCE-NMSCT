// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/profile.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class CreateClassRoom extends StatefulWidget {
  const CreateClassRoom({
    super.key,
    required this.role,
    required this.admin_id,
    required this.purpose,
    required this.refreshCallback,
  });
  final String role;

  final String admin_id;

  final String purpose;

  final VoidCallback refreshCallback;
  @override
  State<CreateClassRoom> createState() => _CreateClassRoomState();
}

class _CreateClassRoomState extends State<CreateClassRoom> {
  final code = TextEditingController();
  final location = TextEditingController();

  void getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permission Not given");
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      print("Latitude : ${currentPosition.latitude}");
      print("Longitude : ${currentPosition.longitude}");
      String lat = currentPosition.latitude.toString();
      String long = currentPosition.longitude.toString();
      setState(() {
        location.text = lat + long;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Create '),
            Text(widget.purpose),
          ],
        ),
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
                  const UserProfile(),
                  Divider(
                    color: Colors.grey[600],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Type ${widget.purpose} first, code will be generated after',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
                  Column(
                    children: [
                      TextField(
                        controller: code,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: Style.textdesign.copyWith(
                            hintText: widget.role == 'Admin'
                                ? 'Section Name'
                                : 'Establishment Name'),
                      ),
                      SizedBox(height: 10),
                      widget.role == 'Establishment'
                          ? TextFormField(
                              readOnly: true,
                              controller: location,
                              decoration: Style.textdesign.copyWith(
                                  labelText: 'Location',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.location_pin),
                                    onPressed: () {
                                      getCurrentPosition();
                                      // _idController.text = id;
                                    },
                                  )),
                            )
                          : SizedBox(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final String pin = code.text;
                            final String loc = location.text;

                            if (pin.isEmpty) {
                              String title = "Name Empty !";
                              String message = "Input name";
                              await showAlertDialog(context, title, message);
                            } else if (widget.role == "Establishment" &&
                                loc.isEmpty) {
                              String title = "Invalid Location !";
                              String message = "register gps";
                              await showAlertDialog(context, title, message);
                            } else {
                              String title = "Success";
                              String message = "click to copy";
                              String code = generateAlphanumericId();
                              await CreateSectEstab(
                                context,
                                code,
                                pin,
                                loc,
                                widget.admin_id,
                              );
                              // await pasteCode(context, title, message, code);
                              // String purpose = 'CreateClassRoom';
                              // await CreateSectEstab(context, pin);
                              // await showAlertDialog(context, mess, path);
                              Navigator.of(context).pop(false);
                              widget.refreshCallback();
                            }
                          },
                          child: Text(
                            "Enter",
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
