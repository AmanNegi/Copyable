import 'dart:developer';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/helper/logger.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class StaticData extends ChangeNotifier {
  List<CopyableItem> _items = [];

  List<CopyableItem> getItems() => [..._items];

  StaticData() {
    localData.getData().then((value) {
      log("Data From Local Device : $value");
      _items = value;
      notifyListeners();
    });
  }

  void addData(CopyableItem item) {
    _items.add(item);
    notifyListeners();

    localData.addData(item);
    if (isLoggedIn()) {
      cloudDatabase.addDataToUserList(item);
    }
  }

  void replaceList(List<CopyableItem> items) {
    _items = [...items];
    notifyListeners();
  }

  void addDataFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text!.isEmpty) {
      showToast("Empty Clipboard");
      return;
    }

    Logger.logData("Adding: ${data.text}", shorten: true);

    var item = CopyableItem(
      text: data.text!.trim(),
      id: localData.getAvailableID(),
      time: DateTime.now(),
    );
    addData(item);
  }

  void removeData(String id) {
    log("Finding : $id in $_items");
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        _items.removeAt(i);
        log("Deleted Successfully");
        localData.updateCompleteList(_items);

        return;
      }
    }
    log("No Data Found");
  }

  Future<void> updateData(CopyableItem item) async {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == item.id) {
        _items[i] = item;
        notifyListeners();

        log("Updated Successfully");
        return;
      }
    }
    log("Update Unsuccessfull");
  }
}

Future<CopyableItem> getRandomCopyableItem() async {
  return CopyableItem(
    id: localData.getAvailableID(),
    text: "ABC",
    time: DateTime.now(),
  );
}

void saveDataToClipBoard(String data) {
  Clipboard.setData(ClipboardData(text: data));
  showToast("Copied text to Clipboard");
}
