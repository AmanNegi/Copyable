import 'package:copyable/colors.dart';
import 'package:flutter/material.dart';

class AppData {
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  bool isFirstTime;
  bool shownInstructions;
  String uid;
  String username;
  String email;
  late Color globalColor;
  double fontSize;

  AppData({
    required bool loggedIn,
    required this.uid,
    required this.username,
    required this.email,
    required this.shownInstructions,
    this.isFirstTime = true,
    this.globalColor = defaultColor,
    this.fontSize = 15,
  }) {
    isLoggedIn.value = loggedIn;
  }

  Map<String, dynamic> toJson() {
    return {
      "isLoggedIn": isLoggedIn.value,
      "uid": uid,
      'email': email,
      'username': username,
      'isFirstTime': isFirstTime,
      'fontSize': fontSize,
      'globalColor': globalColor.value,
      'shownInstructions': shownInstructions,
    };
  }

  factory AppData.fromJson(Map<String, dynamic> map) {
    return AppData(
      loggedIn: map['isLoggedIn'],
      uid: map['uid'],
      username: map['username'],
      isFirstTime: map['isFirstTime'],
      globalColor: Color(map['globalColor']),
      fontSize: map['fontSize'] ?? 17,
      email: map['email'],
      shownInstructions: map['shownInstructions'],
    );
  }

  @override
  String toString() {
    return "{ ${isLoggedIn.value} , $uid, $email, $username, $isFirstTime, $globalColor $fontSize}";
  }
}
