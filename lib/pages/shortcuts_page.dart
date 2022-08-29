import 'dart:async';
import 'dart:developer';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/pages/home/desktop_home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({Key? key}) : super(key: key);

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage> {
  late StreamSubscription<html.KeyboardEvent> subs;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      subs = html.window.onKeyDown.listen(null);

      subs.onData((html.KeyboardEvent event) {
        log("Shortcuts Page ${event.key}");
        if (event.key == 'Escape') {
          event.preventDefault();
          selectedIndex.value = 0;
        }
        if (event.key == 'F1') {
          event.preventDefault();
          selectedIndex.value = 0;
        }
      });
    }

    selectedIndex.addListener(selectedIndexListener);
  }

  void selectedIndexListener() {
    if (selectedIndex.value != 2) {
      subs.cancel();
      selectedIndex.removeListener(selectedIndexListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
    );
  }

  SingleChildScrollView _getBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 0.1 * MediaQuery.of(context).size.width,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.1 * MediaQuery.of(context).size.height),
                _getHeading("Home Page"),
                _getShortcutTile("Save item from clipboard", "Ctrl + V"),
                const Divider(),
                _getShortcutTile("Navigate to Add Item Page", "/"),
                const Divider(),
                _getShortcutTile("Navigate to Search Page", "Ctrl + F"),
                const Divider(),
                _getShortcutTile("View Shortcuts", "F1"),
                const Divider(),
                _getShortcutTile("Copy 1st Item", "1"),
                const Divider(),
                _getShortcutTile("Copy 2nd Item", "2"),
                const Divider(),
                _getShortcutTile("Copy 3rd Item", "3"),
                const Divider(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.1 * MediaQuery.of(context).size.height),
                _getHeading("Add Item Page"),
                _getShortcutTile("Save Item", "Alt + Enter"),
                const Divider(),
                _getShortcutTile("Discard Item", "Esc"),
                const SizedBox(height: 20),
                _getHeading("Shortcut Page"),
                _getShortcutTile("Go Back", "Esc / F1"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _getShortcutTile(String text, String shortcut) {
    return ListTile(
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      trailing: Text(
        shortcut,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  _getHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: (appData.value.fontSize + 8),
            ),
      ),
    );
  }

  @override
  void dispose() {
    if (kIsWeb) subs.cancel();
    log("Disposed Shortcut Page Listener");
    super.dispose();
  }
}

final escapeKeySet = LogicalKeySet(
  LogicalKeyboardKey.escape,
);

class EscapeIntent extends Intent {}
