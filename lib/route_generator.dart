import 'package:copyable/pages/add_upate_page.dart';
import 'package:copyable/pages/auth/desktop/desktop_auth_page.dart';
import 'package:copyable/pages/auth/mobile/login_page.dart';
import 'package:copyable/pages/auth/mobile/signup_page.dart';
import 'package:copyable/pages/home_page.dart';
import 'package:copyable/pages/search_page.dart';
import 'package:copyable/pages/settings_page.dart';
import 'package:copyable/pages/shortcuts_page.dart';
import 'package:copyable/widgets/responsive.dart';
import 'package:flutter/material.dart';

Route<dynamic> getRoutes(RouteSettings settings) {
  Map args = {};
  if (settings.arguments != null) {
    args = settings.arguments as Map;
  }

  switch (settings.name) {
    case homeRoute:
      return getMaterialPageRoute(const HomePage());
    case loginRoute:
      return getMaterialPageRoute(const Responsive(
        mobile: LoginPage(),
        tablet: DesktopAuthPage(),
        desktop: DesktopAuthPage(),
      ));
    case signUpRoute:
      return getMaterialPageRoute(const Responsive(
        mobile: SignUpPage(),
        tablet: DesktopAuthPage(),
        desktop: DesktopAuthPage(),
      ));
    case shortcutsRoute:
      return getMaterialPageRoute(const ShortcutsPage());
    case searchRoute:
      return getMaterialPageRoute(const SearchPage());

    case settingsRoute:
      return getMaterialPageRoute(const SettingsPage());

    case createEditRoute:
      return getMaterialPageRoute(args.isEmpty
          ? const AddUpdatePage()
          : AddUpdatePage(
              edit: args['edit'],
              oldItem: args['oldItem'],
            ));
    default:
      return getMaterialPageRoute(const LoginPage());
  }
}

MaterialPageRoute getMaterialPageRoute(Widget destinationWidget) {
  return MaterialPageRoute(builder: (context) => destinationWidget);
}

const String createEditRoute = '/create-updateRoute';
const String homeRoute = "/homeRoute";
const String loginRoute = "/loginRoute";
const String signUpRoute = "/signUpRoute";
const String shortcutsRoute = "/shortcutsRoute";
const String searchRoute = "/searchRoute";
const String settingsRoute= "/settingsRoute";
