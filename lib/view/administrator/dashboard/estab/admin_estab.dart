import 'package:attendance_nmsct/view/student/dashboard/establishment/estab_dtr.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/face_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../student/dashboard/establishment/estab_room.dart';

class AdminEstab extends StatefulWidget {
  const AdminEstab({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  State<AdminEstab> createState() => _AdminEstabState();
}

class _AdminEstabState extends State<AdminEstab> {
  // int current = 0;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AdminEstab"),
        centerTitle: true,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.grey[200],
      //   items: const [
      //       // Hero(tag: icon, child: FaIcon(icon.iconData))
      //     BottomNavigationBarItem(
      //         icon: FaIcon(FontAwesomeIcons.locationDot), label: 'Location'),
      //           BottomNavigationBarItem(
      //         icon: FaIcon(FontAwesomeIcons.calendar), label: 'DTR'),
      //     BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.building), label: 'On-site'),
      //     BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
      //   ],
      //   currentIndex: current,
      //   onTap: (int index) {
      //     setState(() {
      //       current = index;
      //     });
      //   },
      // ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.locationDot), label: 'GPS'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendar), label: 'DTR'),
          // BottomNavigationBarItem(
          //     icon: FaIcon(FontAwesomeIcons.building), label: 'On-site'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FaceAuth(id: widget.id, name: widget.name),
          EstabDTR(),
          // const EstabOnsite(),
          EstabRoom(ids: widget.id, name: widget.name),
        ],
      ),
    );
  }
}
