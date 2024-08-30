import 'dart:convert';
import 'package:attendance_nmsct/controller/Insert_Announcement.dart';
import 'package:attendance_nmsct/data/server.dart';
import 'package:attendance_nmsct/widgets/accomplishment_alert.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnnouncementModel {
  final String message;
  final String id;

  AnnouncementModel({required this.message, required this.id});

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      message: json['messageA'],
      id: json['an_id'],
    );
  }
}

class Announcement extends StatefulWidget {
  const Announcement({Key? key}) : super(key: key);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  TextEditingController _announcement = TextEditingController();
  List<String> _userEmails = []; // List to hold user emails

  Future<List<AnnouncementModel>> fetchData() async {
    final response = await http
        .get(Uri.parse('${Server.host}users/student/all_announcement.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchUserEmails() async {
    try {
      final response = await http.get(Uri.parse(
          '${Server.host}users/establishment/get_all_students_email.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<String> userEmails =
            data.map((email) => email['email'].toString()).toList();

        setState(() {
          _userEmails = userEmails;
        });

        print("ALL EMAILS: ${_userEmails}");
      } else {
        throw Exception('Failed to load user emails');
      }
    } catch (e) {
      print('Error fetching user emails: $e');
      // Handle error, e.g., show error message to the user
    }
  }

  Future<void> deleteAnnouncement(id) async {
    String apiUrl = '${Server.host}users/student/delete_announcement.php';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {"id": id});
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final status = jsonResponse['status'];
        final message = jsonResponse['message'];
        await accAlertDialog(context, status, message);
      } else {
        print(
            'Failed to delete announcement. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting announcement: $e');
    }
  }

  Widget _buildMessageWithLineBreaks(String message) {
    String formattedMessage = message.replaceAll('<br>', '\n');
    return Text(
      formattedMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _announcement,
              decoration: InputDecoration(
                labelText: 'Add announcement...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String message = _announcement.text;
                if (message.isEmpty) {
                  await accAlertDialog(
                      context, "Empty", "Cannot add empty message");
                } else {
                  await fetchUserEmails(); // Fetch user emails
                  await insertAnnouncement(context, message, _userEmails);
                  _announcement.clear();
                  setState(() {});
                }
              },
              child: Text('Add Announcement'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<AnnouncementModel>>(
                stream: Stream.fromFuture(fetchData()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<AnnouncementModel> announcements = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: _buildMessageWithLineBreaks(
                              announcements[index].message),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              print(
                                  "Announcement ID: ${announcements[index].id}");
                              await deleteAnnouncement(announcements[index].id);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
