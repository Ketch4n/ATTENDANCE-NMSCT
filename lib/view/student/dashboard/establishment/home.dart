import 'package:attendance_nmsct/view/student/dashboard/establishment/student_estab_dtr.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/student_estab_onsite.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/student_estab_room.dart';
import 'package:attendance_nmsct/view/student/dashboard/establishment/student_face_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Establishment extends StatefulWidget {
  const Establishment({
    super.key,
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  State<Establishment> createState() => _EstablishmentState();
}

class _EstablishmentState extends State<Establishment> {
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
        // backgroundColor:
        //     Colors.transparent,
        // elevation: 0.0,
        flexibleSpace: Stack(
          children: <Widget>[
            Image.asset(
              "assets/images/green.jpg", // Replace with your image path
              fit: BoxFit.cover, // Adjust the fit property as needed
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                foregroundColor: Colors.white,
                backgroundColor:
                    Colors.transparent, // Make the inner AppBar transparent
                elevation: 0.0,
                title: Text(widget.name),
                centerTitle: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.locationDot), label: 'GPS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'DTR'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.building), label: 'On-site'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StudentFaceAuth(id: widget.id, name: widget.name),
          StudentEstabDTR(id: widget.id),
          const StudentEstabOnsite(),
          StudentEstabRoom(ids: widget.id, name: widget.name),
        ],
      ),
    );
  }
}
