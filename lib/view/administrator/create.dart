// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:async';

import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/functions/generate.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:location/location.dart';
import 'package:location/location.dart';

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
  final longi = TextEditingController();
  final lati = TextEditingController();

  final fulladdress = TextEditingController();
  // StreamSubscription<loc.LocationData>? _positionSubscription;
  @override
  void initState() {
    super.initState();
    getCurrentPosition();

    // Listen to location changes
  }

  @override
  void dispose() {
    fulladdress.dispose();

    getCurrentPosition;

    super.dispose();
  }

  void getCurrentPosition() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    double latitude = locationData.latitude!;
    double longitude = locationData.longitude!;

    getAddress(locationData.latitude!, locationData.longitude!);

    setState(() {
      longi.text = longitude.toString();
      lati.text = latitude.toString();
      location.text = latitude.toString() + longitude.toString();
    });
  }

  void getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      print(placemarks);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[2];
        String address = "";

        address +=
            "${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}";
        print("Full Address: $address");

        setState(() {
          fulladdress.text = address;
        });
      } else {
        print("No address found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ' + widget.purpose),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      widget.role == 'Admin'
                          ? 'Type ${widget.purpose} first, code will be generated after'
                          : 'Click to scan location and save',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
                  Column(
                    children: [
                      widget.role == 'Establishment'
                          ? Container(
                              height: 50,
                              width: 50,
                              decoration: Style.boxdecor.copyWith(
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                color: Colors.redAccent,
                                iconSize: 30,
                                icon: const Icon(Icons.location_pin),
                                onPressed: () {
                                  getCurrentPosition();
                                  // _idController.text = id;
                                },
                              ),
                            )
                          : const SizedBox(),
                      widget.role == 'Establishment'
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child:
                                      kIsWeb ? Text("") : Text(location.text),
                                ),
                                location.text == ''
                                    ? const SizedBox()
                                    : Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 500),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: TextField(
                                            readOnly: true,
                                            controller:
                                                kIsWeb ? location : fulladdress,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            decoration: Style.textdesign
                                                .copyWith(labelText: 'Address'),
                                          ),
                                        ),
                                      ),
                              ],
                            )
                          //  TextFormField(
                          //     readOnly: true,
                          //     controller: location,
                          //     decoration: Style.textdesign.copyWith(
                          //         labelText: 'Location',
                          //         suffixIcon: IconButton(
                          //           icon: const Icon(Icons.location_pin),
                          //           onPressed: () {
                          //             getCurrentPosition();
                          //             // _idController.text = id;
                          //           },
                          //         )),
                          //   )
                          : const SizedBox(),
                      widget.role == 'Establishment' && location.text.isEmpty
                          ? const SizedBox()
                          : Container(
                              constraints: BoxConstraints(maxWidth: 500),
                              child: TextField(
                                controller: code,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: Style.textdesign.copyWith(
                                    labelText: widget.role == 'Admin'
                                        ? 'Section Name'
                                        : 'Establishment Name'),
                              ),
                            ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () async {
                            final String pin = code.text;
                            final String loc = fulladdress.text;
                            final String long_lat = location.text;
                            final String longitude = longi.text;
                            final String latitude = lati.text;

                            if (pin.isEmpty) {
                              String title = "Name Empty !";
                              String message = "Input name";
                              await showAlertDialog(context, title, message);
                            } else if (widget.role == "Establishment" &&
                                long_lat.isEmpty) {
                              String title = "Click location icon";
                              String message = "to register gps";
                              await showAlertDialog(context, title, message);
                            } else {
                              // String title = "Success";
                              // String message = "Section created";
                              String code = generateAlphanumericId();
                              await CreateSectEstab(
                                context,
                                code,
                                pin,
                                loc as String,
                                longitude as double,
                                latitude as double,
                                widget.admin_id,
                              );
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
