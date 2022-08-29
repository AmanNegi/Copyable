import 'dart:developer';

import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/models/app_data.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/widgets/action_button.dart';
import 'package:copyable/widgets/upload_old_items_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: Stack(
        children: [
          Positioned(
            right: -50,
            top: -200,
            child: SvgPicture.asset(
              "assets/shape_1.svg",
              color: defaultColor,
              height: 0.4 * _getHeight(context),
            ),
          ),
          Positioned(
            left: -200,
            bottom: -200,
            child: SvgPicture.asset(
              "assets/shape_2.svg",
              color: defaultColor,
              height: 0.4 * _getHeight(context),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.175 * _getHeight(context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome to",
                          style: TextStyle(
                            fontSize: 40,
                            height: 1,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Copyable!",
                          style: TextStyle(
                            fontSize: 40,
                            height: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.025 * _getHeight(context)),
                        const Text("Let's get back to where we were"),
                        SizedBox(height: 0.1 * _getHeight(context)),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Theme.of(context).cardColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 0.025 * _getHeight(context),
                    ),
                    child: Column(children: [
                      TextField(
                        controller: _emailField,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: "Email"),
                      ),
                      TextField(
                        controller: _passwordField,
                        decoration: const InputDecoration(hintText: "Password"),
                      ),
                      SizedBox(
                          height: 0.05 * MediaQuery.of(context).size.height),
                      ActionButton(
                        onPressed: _onLoginPressed,
                        text: ("Login"),
                      ),
                      SizedBox(
                          height: 0.05 * MediaQuery.of(context).size.height),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Are you a new user? ",
                            style: TextStyle(
                              fontSize: appData.value.fontSize - 3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(signUpRoute);
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: defaultColor,
                                fontWeight: FontWeight.w600,
                                fontSize: appData.value.fontSize - 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  SizedBox(height: 0.1 * MediaQuery.of(context).size.height),
                  GestureDetector(
                    onTap: () async {
                      localData.updateAppData(AppData(
                        email: '',
                        loggedIn: false,
                        isFirstTime: false,
                        uid: '',
                        username: '',
                        shownInstructions: false,
                      ));
                      var list = await localData.getData();
                      if (list.isEmpty) {
                        addData(
                            context: context,
                            text: welcomeText,
                            pinned: true,
                            heading: 'Welcome');
                      }
                      if (mounted) Navigator.of(context).pushNamed(homeRoute);
                    },
                    child: Container(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Center(
                        child: Text(
                          "Continue without an account?",
                          style: TextStyle(
                            fontSize: appData.value.fontSize - 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getHeight(BuildContext context) => MediaQuery.of(context).size.height;

  void _onLoginPressed(Function updateLoading) async {
    String email = _emailField.text;
    String password = _passwordField.text;

    updateLoading(true);
    bool authenticated = await authManager.loginUser(email, password);

    if (authenticated) {
      List data = await localData.getData();
      log("Logged In Successfully. Local Data: ${data.length}");

      if (data.isNotEmpty && mounted) {
        await UploadOldItemsDialog.show(context, data.length, _emailField.text);

        updateLoading(false);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false);
        }
      } else {
        if (mounted) {
          updateLoading(false);
          Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false);
        }
      }
    } else {
      updateLoading(false);
    }
  }
}
