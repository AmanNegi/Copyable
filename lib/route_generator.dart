import 'package:copyable/pages/add_upate_page.dart';
import 'package:copyable/pages/auth/login_page.dart';
import 'package:copyable/pages/auth/signup_page.dart';
import 'package:copyable/pages/home_page.dart';
import 'package:copyable/pages/welcome_page.dart';
import 'package:flutter/material.dart';

Route<dynamic> getRoutes(RouteSettings settings) {
  Map args = {};
  if (settings.arguments != null) {
    args = settings.arguments as Map;
  }

  switch (settings.name) {
    case home:
      return getMaterialPageRoute(const WelcomePage());
    case homeRoute:
      return getMaterialPageRoute(const HomePage());
    case loginRoute:
      return getMaterialPageRoute(const LoginPage());
    case signUpRoute:
      return getMaterialPageRoute(const SignUpPage());

    case createEditRoute:
      return getMaterialPageRoute(args.isEmpty
          ? const AddUpdatePage()
          : AddUpdatePage(edit: args['edit'], text: args['text']));
    default:
      return getMaterialPageRoute(const HomePage());
  }
}

MaterialPageRoute getMaterialPageRoute(Widget destinationWidget) {
  return MaterialPageRoute(builder: (context) => destinationWidget);
}

const String home = '/';
const String createEditRoute = '/create-update';
const String homeRoute = "/HomePage";
const String loginRoute = "/loginRoute";
const String signUpRoute = "/signUpRoute";
