import 'package:attendance_nmsct/controller/Remove.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/admin/home.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalDashCard extends StatefulWidget {
  const GlobalDashCard(
      {super.key,
      required this.id,
      required this.uid,
      required this.name,
      required this.code,
      required this.path,
      required this.refreshCallback});
  final String id;
  final String uid;
  final String name;
  final String code;
  final String path;
  final VoidCallback refreshCallback;
  @override
  State<GlobalDashCard> createState() => _GlobalDashCardState();
}

class _GlobalDashCardState extends State<GlobalDashCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              widget.path == "class"
                  ? Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AdminHome(
                            ids: widget.id,
                            uid: widget.uid,
                            name: widget.name,
                          )))
                  : Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EstabHome(
                            id: widget.id,
                            name: widget.name,
                          )));
            },
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.asset(
                    widget.path == "class"
                        ? 'assets/images/blue.jpg'
                        : 'assets/images/green.jpg',
                    fit: BoxFit.cover,
                    height: 120,
                    width: double.maxFinite,
                  ),
                ),
                Column(children: [
                  ListTile(
                    titleTextStyle: Style.MontserratBold.copyWith(fontSize: 20),
                    iconColor: Colors.white,
                    title: Text(widget.name),
                    subtitle: Text(
                      widget.path == 'class' ? "Section" : "OJT Establishment",
                      style: const TextStyle(color: Colors.white),
                    ),
                    // subtitle: Text("Supervisor"),
                  ),
                ]),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'remove',
                          child: Text('Remove'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'code',
                          child: Text('Copy-code'),
                        ),
                      ];
                    },
                    onSelected: (String value) async {
                      if (value == 'remove') {
                        await removeClassRoom(context, widget.id, widget.path);
                        widget.refreshCallback();
                        print('Refresh Callback Triggered');
                      } else {
                        Clipboard.setData(ClipboardData(
                            text: widget.code)); // Copies 'code' to clipboard
                        // Navigator.of(context).pop(false);
                        // Show a snackbar or any other indication that the text has been copied
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Text copied: ${widget.code}')),
                        );
                      }
                      // print('Selected: $path');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
