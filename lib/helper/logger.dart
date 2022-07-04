import 'dart:developer';

import 'package:flutter/material.dart';

class Logger {
  static void logData(String message, {bool shorten = false}) {
    if (shorten && message.length > 20) {
      log("Data: ${message.substring(0, 20)}");
    }
    log("Data: $message");
  }
}
