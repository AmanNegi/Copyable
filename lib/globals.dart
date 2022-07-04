import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String message) {
  if (!kIsWeb) Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
  );
}
