import 'package:flutter/material.dart';

class AdminIndex extends StatefulWidget {
  const AdminIndex({super.key});

  @override
  State<AdminIndex> createState() => _AdminIndexState();
}

class _AdminIndexState extends State<AdminIndex> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Admin Desktop"),
      ),
    );
  }
}
