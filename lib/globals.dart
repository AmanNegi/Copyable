import 'package:copyable/data/local_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool saveToDevice = false;

showToast(String message, {Color? backgroundColor}) {
  if (!kIsWeb) Fluttertoast.cancel();

  String bgColor;
  if (backgroundColor == null) {
    bgColor = appData.value.globalColor.value.toRadixString(16);
  } else {
    bgColor = backgroundColor.value.toRadixString(16);
  }

  bgColor = "#${bgColor.substring(2)}";
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: 2,
    textColor: Colors.white,
    gravity: ToastGravity.BOTTOM,
    // backgroundColor: appData.value.globalColor,
    webPosition: 'center',
    webBgColor: bgColor,
  );
}

double getWidth(context) => MediaQuery.of(context).size.width;
double getHeight(context) => MediaQuery.of(context).size.height;

