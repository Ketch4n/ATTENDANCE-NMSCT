// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({
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
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        height: height,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Add Announcement"),
            TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(hintText: 'Type here...'),
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
                ElevatedButton(onPressed: () {}, child: const Text("Add"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
