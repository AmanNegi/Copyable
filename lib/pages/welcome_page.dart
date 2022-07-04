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
              child: Text("Log in"),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(signUpRoute);
                },
                child: Text("Sign Up"),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(homeRoute);
              },
              child: Text("Continue without an Account"),
            ),
          ],
        ),
      ),
    );
  }
}
