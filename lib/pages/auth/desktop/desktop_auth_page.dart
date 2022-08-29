import 'dart:developer';

import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/widgets/action_button.dart';
import 'package:copyable/widgets/upload_old_items_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopAuthPage extends StatefulWidget {
  const DesktopAuthPage({Key? key}) : super(key: key);

  @override
  State<DesktopAuthPage> createState() => _DesktopAuthPageState();
}

class _DesktopAuthPageState extends State<DesktopAuthPage> {
  final PageController _pageController = PageController(initialPage: 0);
  late double height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: 0.5 * height,
              bottom: 0.05 * height,
              left: 0.2 * width,
              right: 0.5 * width,
              child: SvgPicture.asset(
                "assets/shape_1.svg",
                color: defaultColor,
              ),
            ),
            Positioned(
              top: 0.05 * height,
              bottom: 0.2 * height,
              left: 0.3 * width,
              right: 0.05 * width,
              child: SvgPicture.asset(
                "assets/shape_2.svg",
                color: defaultColor,
              ),
            ),
            Positioned(
              left: 0.325 * width,
              right: 0.325 * width,
              top: 0,
              bottom: 0,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: _pageController,
                children: [
                  SignUpWidget(
                    goToLoginPage: getPageSwitch(1),
                  ),
                  LogInWidget(
                    goToSignUpPage: getPageSwitch(0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Function getPageSwitch(int pageNumber) {
    return () {
      log("Navigating to $pageNumber");
      _pageController.animateToPage(
        pageNumber,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    };
  }
}

class SignUpWidget extends StatefulHookWidget {
  final Function goToLoginPage;

  const SignUpWidget({
    Key? key,
    required this.goToLoginPage,
  }) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late TextEditingController _emailField, _passwordField, _userNameField;
  @override
  Widget build(BuildContext context) {
    _emailField = useTextEditingController();
    _passwordField = useTextEditingController();
    _userNameField = useTextEditingController();
    return Container(
      margin: getMargin(context),
      decoration: getDecoration(context),
      padding: EdgeInsets.symmetric(
        horizontal: 0.025 * MediaQuery.of(context).size.width,
        vertical: 0.05 * MediaQuery.of(context).size.height,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage("assets/copyable_logo_lg.png"),
            radius: 45,
          ),
          const SizedBox(height: 10),
          const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
          const Spacer(),
          TextField(
            autofocus: true,
            controller: _userNameField,
            decoration: const InputDecoration(hintText: "Username"),
          ),
          TextField(
            controller: _emailField,
            decoration: const InputDecoration(hintText: "Email"),
          ),
          TextField(
            controller: _passwordField,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          const Spacer(),
          ActionButton(
            text: "Get Started",
            onPressed: onSignUpPressed,
            fillColor: defaultColor,
            isFilled: true,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? "),
              GestureDetector(
                onTap: () => widget.goToLoginPage(),
                child: const Text(
                  "Log in",
                  style: TextStyle(
                    color: defaultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onSignUpPressed(Function updateState) async {
    String email = _emailField.text;
    String password = _passwordField.text;
    String username = _userNameField.text;

    updateState(true);
    bool authenticated =
        await authManager.registerUser(email, password, username);

    if (authenticated) {
      List data = await localData.getData();
      log("Signed In Successfully. Local Data: ${data.length}");

      if (data.isNotEmpty && mounted) {
        await UploadOldItemsDialog.show(context, data.length, _emailField.text);

        if (mounted) {
          updateState(false);
          Navigator.pushNamed(context, homeRoute);
        }
      } else {
        await addData(
            context: context,
            text: welcomeText,
            pinned: true,
            heading: 'Welcome');
        if (mounted) {
          updateState(false);
          Navigator.pushNamed(context, homeRoute);
        }
      }
    } else {
      updateState(false);
    }
  }
}

class LogInWidget extends StatefulHookWidget {
  final Function goToSignUpPage;
  const LogInWidget({Key? key, required this.goToSignUpPage}) : super(key: key);

  @override
  State<LogInWidget> createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogInWidget> {
  late TextEditingController _emailField, _passwordField;

  @override
  Widget build(BuildContext context) {
    _emailField = useTextEditingController();
    _passwordField = useTextEditingController();
    return Container(
      margin: getMargin(context),
      decoration: getDecoration(context),
      padding: EdgeInsets.symmetric(
        horizontal: 0.025 * MediaQuery.of(context).size.width,
        vertical: 0.05 * MediaQuery.of(context).size.height,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage("assets/copyable_logo_lg.png"),
            radius: 45,
          ),
          const SizedBox(height: 10),
          const Text(
            "Log in",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
          const Spacer(),
          TextField(
            autofocus: true,
            controller: _emailField,
            decoration: const InputDecoration(hintText: "Email"),
          ),
          TextField(
            controller: _passwordField,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          const Spacer(),
          ActionButton(
            text: "Continue",
            onPressed: (Function updateState) => _onLoginPressed(updateState),
            fillColor: defaultColor,
            isFilled: true,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Are you a new user? "),
              GestureDetector(
                onTap: () => widget.goToSignUpPage(),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: defaultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onLoginPressed(Function updateState) async {
    String email = _emailField.text;
    String password = _passwordField.text;

    updateState(true);
    bool authenticated = await authManager.loginUser(email, password);

    if (authenticated) {
      List data = await localData.getData();
      log("Logged In Successfully. Local Data: ${data.length}");

      if (data.isNotEmpty && mounted) {
        await UploadOldItemsDialog.show(context, data.length, _emailField.text);

        updateState(false);
        if (mounted) Navigator.pushNamed(context, homeRoute);
      } else {
        updateState(false);
        if (mounted) Navigator.pushNamed(context, homeRoute);
      }
    } else {
      updateState(false);
    }
  }
}

BoxDecoration getDecoration(BuildContext context) {
  return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10.0,
          spreadRadius: 5.0,
        )
      ]);
}

EdgeInsets getMargin(BuildContext context) {
  return EdgeInsets.only(
    top: 0.1 * MediaQuery.of(context).size.height,
    bottom: 0.1 * MediaQuery.of(context).size.height,
    left: 10.0,
    right: 10.0,
  );
}
