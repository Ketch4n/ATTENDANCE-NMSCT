import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewSched extends StatefulWidget {
  const ViewSched({super.key, required this.name, required this.id});
  final String name;
  final int id;

  @override
  State<ViewSched> createState() => _ViewSchedState();
}

class _ViewSchedState extends State<ViewSched> {
  TimeOfDay? _time1;
  TimeOfDay? _time2;
  TimeOfDay? _time3;
  TimeOfDay? _time4;

  Future<void> _selectTime(BuildContext context, int index) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        switch (index) {
          case 1:
            _time1 = selectedTime;
            break;
          case 2:
            _time2 = selectedTime;
            break;
          case 3:
            _time3 = selectedTime;
            break;
          case 4:
            _time4 = selectedTime;
            break;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Not Set';
    final now = DateTime.now(); // Use current date
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm').format(dateTime);
  }

  Future<void> _saveTimes() async {
    final times = {
      'ESTAB_ID': widget.id,
      'IN_AM': _formatTime(_time1),
      'OUT_AM': _formatTime(_time2),
      'IN_PM': _formatTime(_time3),
      'OUT_PM': _formatTime(_time4),
    };

    // Convert times map to JSON format
    final jsonTimes = json.encode(times);

    // Call the API or function to save the time data
    await saveTimesToServer(jsonTimes);

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Saved Times'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: times.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveTimesToServer(String jsonData) async {
    String apiUrl =
        '${Server.host}users/admin/create_schedule.php'; // Replace with your actual API URL
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

    if (response.statusCode == 200) {
      print('Times saved successfully');
    } else {
      print('Failed to save times: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildTimePickerButton('IN - AM', _time1, 1),
          _buildTimePickerButton('OUT - AM', _time2, 2),
          _buildTimePickerButton('IN - PM', _time3, 3),
          _buildTimePickerButton('OUT - PM', _time4, 4),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveTimes,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(String label, TimeOfDay? time, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _selectTime(context, index),
            child: Text(label),
          ),
          SizedBox(width: 10),
          Text(
            _formatTime(time),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
