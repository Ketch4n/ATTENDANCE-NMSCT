import 'dart:convert';

import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  late double _currentSliderValue = 0;

  void _actionDone() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('adminEstab');

    try {
      final response = await http.post(
        Uri.parse('${Server.host}users/establishment/update_meter.php'),
        body: {'estab_id': id, 'meter': _currentSliderValue.toString()},
      );
      if (response.statusCode == 200) {
        const title = "Success";
        String content = "Meter Updated Successfully";

        await showAlertDialog(context, title, content);
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void getValue() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('adminEstab');
    final response = await http.post(
        Uri.parse('${Server.host}users/establishment/get_meter.php'),
        body: {
          'id': id,
        });

    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        _currentSliderValue = double.parse(data['radius']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    getValue();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Radius'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Meters : ${_currentSliderValue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 20),
            ),
            Slider(
              value: _currentSliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentSliderValue = 5;
                      });
                    },
                    child: const Text("default")),
                ElevatedButton(
                    onPressed: () {
                      _actionDone();
                    },
                    child: const Text("save")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("cancel"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
