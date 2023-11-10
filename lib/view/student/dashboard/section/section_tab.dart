import 'package:flutter/material.dart';

class SectionTab extends StatefulWidget {
  const SectionTab({super.key});

  @override
  State<SectionTab> createState() => _SectionTabState();
}

class _SectionTabState extends State<SectionTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Section Tab")),
    );
  }
}
