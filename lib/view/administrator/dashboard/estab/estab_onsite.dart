import 'package:flutter/material.dart';

class EstabOnsite extends StatefulWidget {
  const EstabOnsite({super.key});

  @override
  State<EstabOnsite> createState() => _EstabOnsiteState();
}

class _EstabOnsiteState extends State<EstabOnsite> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Text(
          "Push Notification",
        ),
        trailing: Icon(Icons.notification_important));
  }
}
