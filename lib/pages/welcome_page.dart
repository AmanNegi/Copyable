import 'package:copyable/data/local_data.dart';
import 'package:copyable/models/app_data.dart';
import 'package:copyable/route_generator.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(loginRoute);
              },
              child: const Text("Log in"),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(signUpRoute);
                },
                child: const Text("Sign Up"),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                localData.updateAppData(AppData(
                  email: '',
                  loggedIn: false,
                  isFirstTime: false,
                  uid: '',
                  username: '',
                  shownInstructions: false,
                ));
                Navigator.of(context).pushNamed(homeRoute);
              },
              child: const Text("Continue without an Account"),
            ),
          ],
        ),
      ),
    );
  }
}
