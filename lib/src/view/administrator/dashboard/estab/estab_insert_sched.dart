import 'dart:convert';
import 'package:attendance_nmsct/src/data/provider/session.dart';
import 'package:attendance_nmsct/src/model/EstabRoomModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_nmsct/src/data/firebase/server.dart';

class InsertSched extends StatefulWidget {
  const InsertSched({
    super.key,
    this.id,
    this.student,
    required this.onDialogClose,
  });
  final int? id;
  final int? student;
  final VoidCallback
      onDialogClose; // Callback to notify parent when dialog is closed

  @override
  State<InsertSched> createState() => _InsertSchedState();
}

class _InsertSchedState extends State<InsertSched> {
  TimeOfDay? _time1;
  TimeOfDay? _time2;
  TimeOfDay? _time3;
  TimeOfDay? _time4;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;

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

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFrom) {
          _selectedDateFrom = selectedDate;
        } else {
          _selectedDateTo = selectedDate;
        }
      });
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _saveTimes() async {
    final times = {
      'ESTAB_ID': widget.id.toString(),
      'USER_ID': widget.student.toString(),
      'IN_AM': _formatTime(_time1),
      'OUT_AM': _formatTime(_time2),
      'IN_PM': _formatTime(_time3),
      'OUT_PM': _formatTime(_time4),
      'DATE_FROM': _formatDate(_selectedDateFrom),
      'DATE_TO': _formatDate(_selectedDateTo),
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
        '${Server.host}users/admin/create_shift.php'; // Replace with your actual API URL
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
      child: Container(
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "INSERT NEW SCHED",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTimePickerButton('IN - AM', _time1, 1),
            _buildTimePickerButton('OUT - AM', _time2, 2),
            _buildTimePickerButton('IN - PM', _time3, 3),
            _buildTimePickerButton('OUT - PM', _time4, 4),
            const SizedBox(height: 10),
            _buildDatePickerButton('Date From', _selectedDateFrom, true),
            _buildDatePickerButton('Date To', _selectedDateTo, false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTimes,
              child: const Text('Save'),
            ),
          ],
        ),
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

  Widget _buildDatePickerButton(String label, DateTime? date, bool isFrom) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _selectDate(context, isFrom),
            child: Text(label),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
