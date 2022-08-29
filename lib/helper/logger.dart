import 'dart:developer';

class Logger {
  static void logData(String message, {bool shorten = false}) {
    if (shorten && message.length > 5) {
      log("Data: ${message.substring(0, 5)}");
    }
    log("Data: $message");
  }
}
