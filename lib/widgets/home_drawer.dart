import 'package:copyable/data/auth.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/strings.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: const Color(0xFF1E1F25),
        child: Column(children: [
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            height: 0.065 * getHeight(context),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/logo.png"),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appData.value.username,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 15),
                    ),
                    Text(
                      appData.value.email,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontSize: 13,
                            color: fadedTextColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              MdiIcons.scriptTextOutline,
              color: Colors.white.withOpacity(0.5),
            ),
            title: const Text("Lorem Ipsum"),
            onTap: () async {
              saveDataToClipBoard(loremText);
            },
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(settingsRoute);
            },
            leading: Icon(
              MdiIcons.tuneVerticalVariant,
              color: Colors.white.withOpacity(0.5),
            ),
            title: const Text("Settings"),
          ),
          ListTile(
            leading: Icon(
              isLoggedIn()
                  ? MdiIcons.accountLockOutline
                  : MdiIcons.accountLockOpenOutline,
              color: Colors.white.withOpacity(0.5),
            ),
            title: Text(
              isLoggedIn() ? "Log Out" : "Login",
            ),
            onTap: () async {
              if (isLoggedIn()) {
                await authManager.signOutUser();
              }
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, loginRoute, (route) => false);
              }
            },
          ),
          if (!isLoggedIn())
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Colors.white.withOpacity(0.5),
              ),
              title: const Text("Clear AppData"),
              onTap: () async {
                await localData.updateCompleteList([]);
                if (mounted) {
                  Provider.of<StaticData>(context, listen: false).refreshData();
                  showToast("Cleared the app data",
                      backgroundColor: Colors.green);
                }
              },
            ),
          ListTile(
            leading: Icon(
              MdiIcons.informationVariant,
              color: Colors.white.withOpacity(0.5),
            ),
            title: const Text("About Us"),
            onTap: () async {
              await launchUrl(
                  Uri.parse(
                      "https://github.com/AmanNegi/AmanNegi.github.io/blob/main/copyable/README.md"),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ]),
      ),
    );
  }
}
