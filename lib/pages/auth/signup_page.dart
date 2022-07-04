import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/models/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../globals.dart';
import '../../route_generator.dart';

class SignUpPage extends StatefulHookWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _emailField, _passwordField;
  @override
  Widget build(BuildContext context) {
    _emailField = useTextEditingController();
    _passwordField = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            SizedBox(height: 0.2 * MediaQuery.of(context).size.height),
            TextField(
              controller: _emailField,
              decoration: InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: _passwordField,
              decoration: InputDecoration(hintText: "Password"),
            ),
            SizedBox(height: 0.05 * MediaQuery.of(context).size.height),
            ElevatedButton(
              onPressed: () async {
                String email = _emailField.text;
                String password = _passwordField.text;

                bool authenticated =
                    await authManager.registerUser(email, password, "Aster");

                if (authenticated) {
                  await localData.updateAppData(AppData(
                    loggedIn: true,
                    uid: authManager.auth.currentUser!.uid,
                  ));
                  if (mounted) Navigator.pushNamed(context, homeRoute);
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
