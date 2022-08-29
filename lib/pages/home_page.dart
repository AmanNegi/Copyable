import 'package:copyable/pages/home/desktop_home_page.dart';
import 'package:copyable/pages/home/mobile_home_page.dart';
import 'package:copyable/widgets/responsive.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileHomePage(),
      tablet: DesktopHomePage(),
      desktop: DesktopHomePage(),
    );
  }
}
