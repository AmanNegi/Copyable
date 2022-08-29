import 'dart:convert';
import 'dart:developer';

import 'package:copyable/models/app_data.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const String dataKey = "local_data";
const String appDataKey = "app_data";
const String localUpperBound = "local_upper_bound";

ValueNotifier<AppData> appData = ValueNotifier(AppData(
  loggedIn: false,
  uid: '',
  username: '',
  email: '',
  isFirstTime: true,
  shownInstructions: false,
));

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
    if (!_sharedPreferences!.containsKey(dataKey)) {
      return [];
    }
    List<CopyableItem> dataList = [];
    String data = _sharedPreferences!.getString(dataKey)!;
    List items = json.decode(data);

    for (var e in items) {
      dataList.add(CopyableItem.fromJson(e));
    }

    return dataList;
  }

  Future<void> updateCompleteList(List<CopyableItem> list) async {
    await initSharedPrefs();
    await _sharedPreferences!.setString(dataKey, json.encode(list));
    log("local_data.dart: Updated Data to ${json.encode(list)}");
  }

  String getAvailableID() {
    return uuid.v1();
  }

//* Local Data Related Functions
  Future initAppData() async {
    await initSharedPrefs();
    if (_sharedPreferences!.containsKey(appDataKey)) {
      AppData data = AppData.fromJson(
          json.decode(_sharedPreferences!.getString(appDataKey)!));
      appData.value = data;
      log("local_data.dart: Init App Data $data");
    } else {
      _sharedPreferences!
          .setString(appDataKey, json.encode(appData.value.toJson()));
      log("local_data.dart: First Time Inititaing App Data to : ${appData.value}");
    }
  }

  Future updateAppData(AppData data) async {
    await initSharedPrefs();
    if (_sharedPreferences!.containsKey(appDataKey)) {
      appData.value = data;
      _sharedPreferences!.setString(appDataKey, json.encode(data.toJson()));
      log("local_data.dart: Updated App Data to $data");
    }
  }

  Future updateColorData(Color newColor) async {
    await initSharedPrefs();

    AppData data = getNewAppData();
    data.globalColor = newColor;
    await updateAppData(data);
  }

  Future updateFontSize(double fontSize) async {
    await initSharedPrefs();

    AppData data = getNewAppData();
    data.fontSize = fontSize;
    await updateAppData(data);
  }

  Future updateShownInstructions(bool value) async {
    await initSharedPrefs();

    AppData data = getNewAppData();
    data.shownInstructions = value;
    await updateAppData(data);
  }

  AppData getNewAppData() {
    return AppData(
      email: appData.value.email,
      loggedIn: appData.value.isLoggedIn.value,
      uid: appData.value.uid,
      username: appData.value.username,
      fontSize: appData.value.fontSize,
      isFirstTime: appData.value.isFirstTime,
      globalColor: appData.value.globalColor,
      shownInstructions: appData.value.shownInstructions,
    );
  }
}

LocalData localData = LocalData();
