import 'dart:developer';

import 'package:flutter/foundation.dart' show kDebugMode;

class Logger {
  static void logError({required String message, required String name}) {
    if (kDebugMode) {
      log(
        message,
        name: name,
        time: DateTime.now(),
      );
    } else {
      // Log to your preferred logging mechanism in non-debug mode
      // For example, you can use the logger package: https://pub.dev/packages/logger
      // logger.e(error);
    }
  }
}
