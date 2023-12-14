import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_dtr.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_face_auth.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_onsite.dart';
import 'package:attendance_nmsct/view/administrator/dashboard/estab/estab_room.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EstabHome extends StatefulWidget {
  const EstabHome({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  State<EstabHome> createState() => _EstabHomeState();
}

class _EstabHomeState extends State<EstabHome> {
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
        title: const Text("Establishment"),
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
              icon: FaIcon(FontAwesomeIcons.sun), label: 'Today'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendar), label: 'Attendance'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.building), label: 'On-site'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EstabFaceAuth(id: widget.id, name: widget.name),
          EstabDTR(id: widget.id, name: widget.name),
          const EstabOnsite(),
          EstabRoom(ids: widget.id, name: widget.name),
        ],
      ),
    );
  }
}
