import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/utils/loggers.dart';

Future<bool> checkUserConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true; // Connected to the internet
    } else {
      return false; // No internet connection
    }
  } on SocketException catch (e) {
    Logger.logError(message: e.message, name: "Socket Exception");
    return false; // No internet connection
  } on TimeoutException catch (e) {
    Logger.logError(message: e.message ?? '', name: "Timeout Exception");
    return false; // Timeout occurred, no internet connection
  }
}

Size? screenSize;

void getScreenSize(BuildContext context) {
  screenSize = MediaQuery.of(context).size;
}

String getDeviceType() {
  if (Platform.isAndroid) {
    return 'ANDROID';
  } else {
    return 'IOS';
  }
}
