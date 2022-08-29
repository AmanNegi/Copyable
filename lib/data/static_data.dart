import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';

import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/material.dart';
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

  void refreshData() async {
    var value = await localData.getData();
    _items = value;
    notifyListeners();
  }

  Future<bool> addData(CopyableItem item) async {
    _items.add(item);
    notifyListeners();
    localData.updateCompleteList(getItems());

    return true;
  }

  void replaceList(List<CopyableItem> items) {
    _items = [...items];
    notifyListeners();
  }

  void toggleIsPinned(String id, bool value) {
    int res = getIndex(id);
    if (res >= 0) {
      _items[res].isPinned = value;
      value ? _items[res].pinnedTime = DateTime.now() : null;
      notifyListeners();
      log("${value ? 'Pinned' : 'UnPinned'} Successfully");
      return;
    }
    log("An error occured while pinning");
  }

  void removeData(String id) {
    log("Finding : $id in $_items");

    int res = getIndex(id);
    if (res >= 0) {
      _items.removeAt(res);
      log("Deleted Successfully");
      localData.updateCompleteList(_items);
      notifyListeners();
      return;
    }

    log("No Data Found");
  }

  void updateData(CopyableItem item) {
    int res = getIndex(item.id);
    if (res >= 0) {
      _items[res] = item;
      notifyListeners();
      localData.updateCompleteList(getItems());
      log("Updated Successfully");
      return;
    }

    log("Update Unsuccessfull");
  }

  int getIndex(String id) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        return i;
      }
    }
    log("An Error Occured");
    return -1;
  }

  Future<List<CopyableItem>> searchItems(String query) async {
    var items = getItems();

    List<CopyableItem> filteredList = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i].text.contains(query)) {
        filteredList.add(items[i]);
      }
    }
    return filteredList;
  }
}

void saveDataToClipBoard(String data) {
  Clipboard.setData(ClipboardData(text: data));
  showToast("Copied text to Clipboard", backgroundColor: Colors.green);
}

String getHeadingFromContent(String data) {
  int subStrLen = (data.length > 30 ? 30 : data.length);
  return data.substring(0, subStrLen);
}
