import 'dart:convert';
import 'package:attendance_nmsct/data/server.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_view/calendar_view.dart';
import 'package:excel/excel.dart';

class InternReport extends StatefulWidget {
  const InternReport({super.key});

  @override
  _InternReportState createState() => _InternReportState();
}

class _InternReportState extends State<InternReport> {
  List<dynamic> jsonData = []; // Added to store fetched data

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('${Server.host}users/establishment/calendar.php'),
      );

      if (response.statusCode == 200) {
        setState(() {
          jsonData = json.decode(response.body);
        });
      } else {
        // Handle error
        print('Failed to load data');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching data: $e');
    }
  }

  Future<void> exportToExcel(List<dynamic> filteredProducts) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow(
        ['Email', 'Last Name', 'In-AM', 'Out-AM', 'In-PM', 'Out-PM', 'Date']);

    // Add data rows
    for (var product in filteredProducts) {
      sheet.appendRow([
        product['email'],
        product['lname'],
        product['time_in_am'],
        product['time_out_am'],
        product['time_in_pm'],
        product['time_out_pm'],
        product['date']
      ]);
    }

    // Save the Excel file
    var file = '${DateTime.now().toIso8601String()}.xlsx';
    excel.save(fileName: file);
  }

  @override
  Widget build(BuildContext context) {
    List<CalendarEventData> events = [];

    for (var data in jsonData) {
      events.add(CalendarEventData(
        date: DateTime.parse(data['date']),
        title: "${data['lname']}",
        // description:
        //     "Time In: ${data['time_in_am']} - Time Out: ${data['time_out_pm']}",
        startTime: DateTime.parse('${data['date']} ${data['time_in_am']}'),
        endTime: DateTime.parse('${data['date']} ${data['time_out_pm']}'),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Calendar Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                exportToExcel(jsonData);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.green), // Change the color here
              ),
              child: const Text('View Details in Excel',
                  style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CalendarControllerProvider(
          controller: EventController()..addAll(events),
          child: const MonthView(),
        ),
      ),
    );
  }
}
