import 'package:attendance_nmsct/include/style.dart';
import 'package:attendance_nmsct/src/auth/login/login_function.dart';
import 'package:attendance_nmsct/src/auth/login/modules/login_header.dart';
import 'package:attendance_nmsct/src/auth/login/modules/login_subheader.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: Style.login,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                addLoginHeader(),
                addLoginSubHeader(),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: Style.padding,
                    child: Column(
                      children: [
                        TextField(
                          controller: usernameController,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration:
                              Style.textdesign.copyWith(hintText: "Username"),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          obscureText: _isObscure,
                          enableSuggestions: false,
                          controller: passwordController,
                          decoration: Style.textdesign.copyWith(
                            hintText: "Password",
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                }),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () async {
                            final email = usernameController.text.trim();
                            final password = passwordController.text.trim();
                            await login(context, email, password);
                          },
                          autofocus: true,
                          style: TextButton.styleFrom(
                              fixedSize: const Size.fromHeight(50),
                              backgroundColor: Style.themecolor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: Style.radius12)),
                          child: Center(
                            child: Text(
                              'LOG IN',
                              style: Style.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
