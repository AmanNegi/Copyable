import 'dart:developer';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<String?> getClipBoardData(BuildContext context) async {
  ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
  if (data == null || data.text == null || data.text!.trim().isEmpty) {
    showToast("Empty Clipboard", backgroundColor: Colors.red);
    return null;
  }
  return data.text!.trim();
}

Future<void> addData(
    {required BuildContext context,
    required String text,
    required String heading,
    bool pinned = false}) async {
  log("Adding Data : $text");
  CopyableItem item = CopyableItem(
    id: localData.getAvailableID(),
    text: text.trim(),
    time: DateTime.now(),
    isPinned: pinned,
    heading: heading,
    pinnedTime: DateTime.now(),
  );

  if (isLoggedIn()) {
    await cloudDatabase.addDataToUserList(item);
  } else {
    Provider.of<StaticData>(context, listen: false).addData(item);
  }

  showToast("Added Item Successfully", backgroundColor: Colors.green);
}

Future<void> updateData({
  required CopyableItem item,
  required BuildContext context,
  required String updatedText,
  required String headingText,
}) async {
  CopyableItem newItem = CopyableItem(
    id: item.id,
    text: updatedText.trim(),
    time: item.time,
    isPinned: item.isPinned,
    pinnedTime: item.pinnedTime,
    heading: headingText,
  );
  if (isLoggedIn()) {
    await cloudDatabase.updateDataItem(newItem);
  } else {
    Provider.of<StaticData>(context, listen: false).updateData(newItem);
  }
}
