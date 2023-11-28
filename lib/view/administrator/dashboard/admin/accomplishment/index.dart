import 'package:flutter/material.dart';

class AdminAccomplishmentIndex extends StatefulWidget {
  const AdminAccomplishmentIndex({super.key});

  @override
  State<AdminAccomplishmentIndex> createState() =>
      _AdminAccomplishmentIndexState();
}

class _AdminAccomplishmentIndexState extends State<AdminAccomplishmentIndex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Accomplishment")),
    );
  }
}
