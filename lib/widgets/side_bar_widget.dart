import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/pages/home/desktop_home_page.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/strings.dart';
import 'package:copyable/widgets/exit_app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBarWidget extends StatefulWidget {
  const SideBarWidget({Key? key}) : super(key: key);

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  @override
  void initState() {
    super.initState();
    selectedIndex.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _getNavRailItem(0, Icons.cottage),
          _getNavRailItem(1, Icons.add),
          _getNavRailItem(2, MdiIcons.appleKeyboardCommand),
          _getNavRailItem(3, MdiIcons.cloudSearch),
          _getNavRailItem(
            -1,
            isLoggedIn() ? Icons.logout : MdiIcons.accountLockOpen,
            onPressed: () async => await _loginOrLogout(context),
            tooltip: isLoggedIn() ? "Logout" : "Login",
          ),
          const Spacer(),
          _getNavRailItem(
            4,
            MdiIcons.tuneVerticalVariant,
            tooltip: 'Settings',
          ),
          _getNavRailItem(-1, MdiIcons.scriptTextOutline, onPressed: () {
            saveDataToClipBoard(loremText);
          }, tooltip: "Copy Lorem Ipsum Text"),
          _getNavRailItem(-1, MdiIcons.informationVariant, onPressed: () async {
            await launchUrl(
              Uri.parse(
                  "https://github.com/AmanNegi/AmanNegi.github.io/blob/main/copyable/README.md"),
            );
          }, tooltip: "About App"),
        ],
      ),
    );
  }

  Future<void> _loginOrLogout(BuildContext context) async {
    if (isLoggedIn()) {
      ExitAppDialog.show(context, text: "Are you sure you want to Log Out?")
          .then((value) async {
        if (value) {
          await authManager.signOutUser();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, loginRoute, (route) => false);
          }
        }
      });
    } else {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, loginRoute, (route) => false);
      }
    }
  }

  _getNavRailItem(int index, IconData icon,
      {Function? onPressed, String? tooltip}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: tooltip ?? "",
        child: CircleAvatar(
          backgroundColor: selectedIndex.value == index
              ? index == 0
                  ? bgColor
                  : Theme.of(context).primaryColor
              : Colors.transparent,
          child: IconButton(
            onPressed: () {
              if (onPressed != null) {
                onPressed();
                return;
              }

              selectedIndex.value = index;
            },
            icon: index == 0
                ? Image.asset("assets/logo.png")
                : Icon(
                    icon,
                    color: selectedIndex.value == index
                        ? Colors.white
                        : Colors.grey,
                  ),
          ),
        ),
      ),
    );
  }
}
