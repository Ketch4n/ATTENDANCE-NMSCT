import 'dart:async';

import 'package:attendance_nmsct/controller/User.dart';
import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/model/UserModel.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final StreamController<UserModel> _userStreamController =
      StreamController<UserModel>();

  @override
  void initState() {
    super.initState();
    fetchUser(_userStreamController);
  }

  @override
  void dispose() {
    super.dispose();
    _userStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: ClipRRect(
                borderRadius: Style.borderRadius,
                child: Image.asset(
                  "assets/images/admin.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                )),
          ),
          StreamBuilder<UserModel>(
              stream: _userStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name),
                        Text(
                          user.email,
                          textScaleFactor: 0.7,
                        )
                      ],
                    ),
                  );
                }
                return const SizedBox();
              })
        ],
      ),
    );
  }
}
