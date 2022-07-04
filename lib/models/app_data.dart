import 'package:flutter/material.dart';

class AppData {
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  String uid;
  //TODO: add fields later

  AppData({required bool loggedIn, required this.uid}) {
    isLoggedIn.value = loggedIn;
  }

  Map<String, dynamic> toJson() {
    return {
      "isLoggedIn": isLoggedIn.value,
      "uid": uid,
    };
  }

  factory AppData.fromJson(Map<String, dynamic> map) {
    return AppData(
      loggedIn: map['isLoggedIn'],
      uid: map['uid'],
    );
  }

  @override
  String toString() {
    return "{ ${isLoggedIn.value} , $uid}";
  }
}
