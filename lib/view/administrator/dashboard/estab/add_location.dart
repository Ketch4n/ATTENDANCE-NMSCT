import 'package:attendance_nmsct/auth/google/map_google.dart';
import 'package:attendance_nmsct/controller/Create.dart';
import 'package:attendance_nmsct/data/session.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AddLocation extends StatefulWidget {
  const AddLocation(
      {super.key, required this.title, required this.onDialogClose});
  final String title;
  final VoidCallback onDialogClose;

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final bool _default = true;
  bool _show = true;

  String emailStatus = '';
  String location = '';
  late String coordinate = '';
  // String LatLng = '';
  late String lat = '';
  late String lng = '';
  bool done = true;
  bool clicked = false;

  final _controllController = TextEditingController();

  // final _roleController = TextEditingController();
  final _locationController = TextEditingController();

  final _hoursController = TextEditingController();
  final _radiusController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _default && !_show
                ? TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: Style.textdesign.copyWith(
                        hintText: UserSession.location == ""
                            ? 'Address'
                            : UserSession.location),
                  )
                : const SizedBox(),
            _default && !_show
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: _controllController,
                      decoration: Style.textdesign
                          .copyWith(labelText: 'Establishment name'),
                    ),
                  )
                : const SizedBox(),
            _default && !_show
                ? TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _hoursController,
                    decoration:
                        Style.textdesign.copyWith(labelText: 'Hours Required'),
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            _default && !_show
                ? TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _radiusController,
                    decoration: Style.textdesign
                        .copyWith(labelText: 'Radius (default 5 meters)'),
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
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
                            builder: (context) => const MapScreen()),
                      );
                      if (value != null) {
                        setState(() {
                          _show = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text("Click the icon to register Location"),
            ),
            _default && !_show
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                        onPressed: () async {
                          checkTextField();
                        },
                        child: Icon(Icons.save)))
                : SizedBox()
          ],
        ),
      ),
    );
  }

  void checkTextField() async {
    FocusScope.of(context).unfocus();

    String hours = _hoursController.text.trim();

    String loc = UserSession.location.trim();
    String cont = _controllController.text.trim();

    String radius = _radiusController.text.trim();

    if ((loc.isEmpty || cont.isEmpty || hours.isEmpty)) {
      String title = "Please Enter Location Details";
      String message = loc.isEmpty
          ? "Click the location icon and Save"
          : cont.isEmpty
              ? "Input Establishment Name"
              : "Hours required for Interns";
      showAlertDialog(context, title, message);
    } else {
      String currentCoordinate = UserSession.location;
      double? currentLat = UserSession.latitude;
      double? currentLng = UserSession.longitude;
      String radiusMeter = radius.isEmpty ? "5" : radius;
      await CreateSectEstab(context, cont, currentCoordinate, currentLng!,
          currentLat!, hours, radiusMeter);
      widget.onDialogClose();
    }
  }
}
