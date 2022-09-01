import 'dart:developer';

import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/strings.dart';
import 'package:copyable/widgets/action_button.dart';
import 'package:copyable/widgets/upload_old_items_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpPage extends StatefulHookWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _emailField, _passwordField, _userNameField;
  @override
  Widget build(BuildContext context) {
    _emailField = useTextEditingController();
    _passwordField = useTextEditingController();
    _userNameField = useTextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -100,
            bottom: -0.1 * _getHeight(context),
            child: SvgPicture.asset(
              "assets/shape_2.svg",
              color: defaultColor,
              height: 0.25 * _getHeight(context),
            ),
          ),
          Positioned(
            right: -50,
            top: -200,
            child: SvgPicture.asset(
              "assets/shape_1.svg",
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
                        const Text("Get started by creating an account"),
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
                    child: Column(
                      children: [
                        TextField(
                          controller: _userNameField,
                          decoration:
                              const InputDecoration(hintText: "Username"),
                        ),
                        TextField(
                          controller: _emailField,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email",
                          ),
                        ),
                        TextField(
                          controller: _passwordField,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Password",
                          ),
                        ),
                        SizedBox(height: 0.05 * _getHeight(context)),
                        ActionButton(
                          onPressed: onSignUpPressed,
                          text: ("Sign Up"),
                        ),
                        SizedBox(height: 0.05 * _getHeight(context)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: appData.value.fontSize - 3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed(loginRoute);
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: defaultColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: appData.value.fontSize - 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void onSignUpPressed(Function updateState) async {
    String email = _emailField.text;
    String password = _passwordField.text;
    String username = _userNameField.text;

    updateState(true);
    bool authenticated =
        await authManager.registerUser(email, password, username);

    await addData(
        context: context, text: welcomeText, pinned: true, heading: "Welcome");
    if (authenticated) {
      List data = await localData.getData();
      log("Signed In Successfully. Local Data: ${data.length}");

      if (data.isNotEmpty && mounted) {
        await UploadOldItemsDialog.show(context, data.length, _emailField.text);

        if (mounted) {
          updateState(false);
          Navigator.pushNamedAndRemoveUntil(context, homeRoute, (e) => false);
        }
      } else {
        if (mounted) {
          updateState(false);

          Navigator.pushNamedAndRemoveUntil(context, homeRoute, (e) => false);
        }
      }
    } else {
      updateState(false);
    }
  }
}
