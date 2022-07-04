import 'dart:developer';

import 'package:copyable/data/auth.dart';
import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/models/app_data.dart';
import 'package:copyable/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../globals.dart';

class LoginPage extends StatefulHookWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailField, _passwordField;
  @override
  Widget build(BuildContext context) {
    _emailField = useTextEditingController();
    _passwordField = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            SizedBox(height: 0.2 * MediaQuery.of(context).size.height),
            TextField(
              controller: _emailField,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: _passwordField,
              decoration: const InputDecoration(hintText: "Password"),
            ),
            SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
            ElevatedButton(
              onPressed: () => _onLoginPressed(),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed() async {
    String email = _emailField.text;
    String password = _passwordField.text;

    bool authenticated = await authManager.loginUser(email, password);

    if (authenticated) {
      await localData.updateAppData(
        AppData(loggedIn: true, uid: authManager.auth.currentUser!.uid),
      );
      List data = await localData.getData();
      log("Logged In Successfully. Local Data: ${data.length}");

      if (data.isNotEmpty) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Warning'),
                content: Text(
                    'You have ${data.length} items in your device. Do you want to upload the data to the server or start afresh?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('UPLOAD'),
                  ),
                ],
              );
            }).then(
          (value) async {
            if (value) {
              await cloudDatabase.uploadLocalDataToCloud(_emailField.text);
            } else {
              //TODO: Clear Provider Data as well
              localData.updateCompleteList([]);
            }
          },
        );
      }
      if (mounted) Navigator.pushNamed(context, homeRoute);
    }
  }
}
