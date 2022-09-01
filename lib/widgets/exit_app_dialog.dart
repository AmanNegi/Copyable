import 'package:copyable/data/local_data.dart';
import 'package:copyable/colors.dart';
import 'package:flutter/material.dart';

class ExitAppDialog extends StatefulWidget {
  final String title;

  const ExitAppDialog({
    Key? key,
    this.title = 'Are you sure you want to exit?',
  }) : super(key: key);

  @override
  State<ExitAppDialog> createState() => _ExitAppDialogState();

  static Future<bool> show(BuildContext context, {String? text}) async {
    bool res = await showDialog<bool>(
          context: context,
          builder: (context) => text != null
              ? ExitAppDialog(
                  title: text,
                )
              : const ExitAppDialog(),
        ) ??
        false;
    return res;
  }
}

class _ExitAppDialogState extends State<ExitAppDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardColor,
      title: const Text('Exit app'),
      content: Text(
        widget.title,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            'CANCEL',
            style: TextStyle(color: appData.value.globalColor),
          ),
        ),
        ElevatedButton(
          style: TextButton.styleFrom(
            primary: appData.value.globalColor,
            backgroundColor: appData.value.globalColor,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text(
            'CONFIRM',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
