// ignore_for_file: must_be_immutable
import 'package:attendance_nmsct/data/server.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DialogBox extends StatefulWidget {
  DialogBox({
    super.key,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height / 2;

    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        height: height,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Add Announcement"),
            TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(hintText: 'Type here...'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(onPressed: () {}, child: Text("Add"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
