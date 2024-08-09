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
  const Announcement({super.key});

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  final TextEditingController _announcement = TextEditingController();
  final List<String> _userEmails = []; // List to hold user emails

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
        title: const Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _announcement,
              decoration: const InputDecoration(
                labelText: 'Add announcement...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String message = _announcement.text;
                String subject = "Attention All Students !";
                if (message.isEmpty) {
                  await accAlertDialog(
                      context, "Empty", "Cannot add empty message");
                } else {
                  await insertAnnouncement(context, message, subject);
                  _announcement.clear();
                  setState(() {});
                }
              },
              child: const Text('Add Announcement'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<AnnouncementModel>>(
                stream: Stream.fromFuture(fetchData()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                        'Are you sure you want to delete this announcement?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirm == true) {
                                await deleteAnnouncement(
                                    announcements[index].id);
                                setState(() {});
                              }
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
