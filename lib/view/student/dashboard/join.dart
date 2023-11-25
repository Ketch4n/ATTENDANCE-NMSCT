// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:attendance_nmsct/controller/Join.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:attendance_nmsct/widgets/user_profile.dart';
import 'package:flutter/material.dart';

class Join extends StatefulWidget {
  const Join({
    super.key,
    required this.role,
    required this.purpose,
    required this.refreshCallback,
  });
  final String role;
  final String purpose;

  final VoidCallback refreshCallback;
  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {
  final code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.role == 'Student' ? 'Join ' : 'Create '),
            Text(widget.purpose),
          ],
        ),
      ),
      body: Column(children: [
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
                UserProfile(),
                Divider(
                  color: Colors.grey[600],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    widget.role == 'Admin'
                        ? 'Type ${widget.purpose} first, code will be generated after'
                        : "Ask for ${widget.purpose} code\nand enter it here",
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
                              : widget.role == "Student"
                                  ? "${widget.purpose} Code"
                                  : "${widget.purpose} Code"),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final String path = widget.purpose == 'Establishment'
                              ? 'establishment'
                              : 'section';
                          final String ref = widget.purpose == 'Establishment'
                              ? 'room'
                              : 'class';
                          final String pin = code.text;
                          const String mess = "You are now in a ";
                          if (pin.isEmpty) {
                            String title = "Code Empty !";
                            String message = "Input code";

                            await showAlertDialog(context, title, message);
                          } else {
                            // String purpose = 'join';
                            await joinClassRoom(context, path, ref, pin);
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
    );
  }
}
