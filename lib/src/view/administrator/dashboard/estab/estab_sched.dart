import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';

class ViewSched extends StatefulWidget {
  const ViewSched(
      {super.key,
      required this.name,
      required this.id,
      required this.onDialogClose});
  final String name;
  final int id;
  final VoidCallback
      onDialogClose; // Callback to notify parent when dialog is closed

  @override
  State<ViewSched> createState() => _ViewSchedState();
}

class _ViewSchedState extends State<ViewSched> {
  TimeOfDay? _time1;
  TimeOfDay? _time2;
  TimeOfDay? _time3;
  TimeOfDay? _time4;

  @override
  void initState() {
    super.initState();
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final format = DateFormat('HH:mm');
    try {
      final dateTime = format.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }

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
    if (time == null) return '';
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
      'ESTAB_ID': widget.id.toString(), // Ensure ID is sent as a string
      'IN_AM': _formatTime(_time1),
      'OUT_AM': _formatTime(_time2),
      'IN_PM': _formatTime(_time3),
      'OUT_PM': _formatTime(_time4),
    };

    // Convert times map to JSON format
    final jsonTimes = json.encode(times);

    // Call the API or function to save the time data
    final success = await saveTimesToServer(jsonTimes);

    // Close the dialog and call the callback
    Navigator.of(context).pop();
    widget.onDialogClose(); // Call the callback here

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Error'),
          content: Text(
              success ? 'Times saved successfully.' : 'Failed to save times.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> saveTimesToServer(String jsonData) async {
    String apiUrl =
        '${Server.host}users/admin/create_schedule.php'; // Replace with your actual API URL
    Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: jsonData);

      if (response.statusCode == 200) {
        print('Times saved successfully');
        return true; // Indicate success
      } else {
        print('Failed to save times: ${response.body}');
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error saving times: $e');
      return false; // Indicate failure
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTimePickerButton('IN - AM', _time1, 1),
          _buildTimePickerButton('OUT - AM', _time2, 2),
          _buildTimePickerButton('IN - PM', _time3, 3),
          _buildTimePickerButton('OUT - PM', _time4, 4),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveTimes,
            child: const Text('Save'),
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
          const SizedBox(width: 10),
          Text(
            _formatTime(time),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
