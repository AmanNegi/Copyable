import 'dart:convert';
import 'dart:developer';

import 'package:copyable/globals.dart';
import 'package:copyable/models/app_data.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const String DATA_KEY = "local_data";
const String APP_DATA = "app_data";
const String LOCAL_UPPER_BOUND = "local_upper_bound";

ValueNotifier<AppData> appData =
    ValueNotifier(AppData(loggedIn: false, uid: ''));
bool isLoggedIn() => appData.value.isLoggedIn.value;

class LocalData {
  SharedPreferences? _sharedPreferences;
  Uuid uuid = const Uuid();

  initSharedPrefs() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

//* Data Related Functions
  Future<List<CopyableItem>> getData() async {
    await initSharedPrefs();
    if (!_sharedPreferences!.containsKey(DATA_KEY)) {
      return [];
    }
    List<CopyableItem> dataList = [];
    String data = _sharedPreferences!.getString(DATA_KEY)!;
    List items = json.decode(data);

    for (var e in items) {
      dataList.add(CopyableItem.fromJson(e));
    }

    return dataList;
  }

  void addData(CopyableItem data) async {
    await initSharedPrefs();
    List<CopyableItem> previousList = await getData();
    previousList.add(data);
    await _sharedPreferences!.setString(DATA_KEY, json.encode(previousList));
    showToast("Added Data Successfully");
  }

  void updateCompleteList(List<CopyableItem> list) async {
    await initSharedPrefs();
    await _sharedPreferences!.setString(DATA_KEY, json.encode(list));
  }

  String getAvailableID() {
    return uuid.v1();
  }

//* Local Data Related Functions
  Future initAppData() async {
    await initSharedPrefs();
    if (_sharedPreferences!.containsKey(APP_DATA)) {
      AppData data = AppData.fromJson(
          json.decode(_sharedPreferences!.getString(APP_DATA)!));
      appData.value = data;
    } else {
      _sharedPreferences!
          .setString(APP_DATA, json.encode(appData.value.toJson()));
    }
  }

  Future updateAppData(AppData data) async {
    log("Updated App Data to $data");
    await initSharedPrefs();
    if (_sharedPreferences!.containsKey(APP_DATA)) {
      appData.value = data;
      _sharedPreferences!.setString(APP_DATA, json.encode(data.toJson()));
    }
  }

}

LocalData localData = LocalData();
