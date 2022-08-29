import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:flutter/material.dart';

class UploadOldItemsDialog extends StatefulWidget {
  final int length;
  const UploadOldItemsDialog({
    Key? key,
    required this.length,
  }) : super(key: key);

  @override
  State<UploadOldItemsDialog> createState() => _UploadOldItemsDialogState();

  static Future<void> show(
      BuildContext context, int length, String email) async {
    bool res = await showDialog<bool>(
          context: context,
          builder: (context) => UploadOldItemsDialog(length: length),
        ) ??
        false;

    if (res) {
      await cloudDatabase.uploadLocalDataToCloud(email);
      showToast("Your local notes were uploaded to $email",
          backgroundColor: Colors.green);
    } else {
      //TODO: Clear Provider Data as well
      await localData.updateCompleteList([]);
    }
  }
}

class _UploadOldItemsDialogState extends State<UploadOldItemsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardColor,
      title: const Text('Warning'),
      content: Text(
        'You have ${widget.length} items in your device. Do you want to upload the data to the server or start afresh?',
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
            'UPLOAD',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
