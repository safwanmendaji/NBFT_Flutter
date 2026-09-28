import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/progress_dialog.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/login/login_screen.dart';

class NavigationUtils {
  static Future<void> logout({required BuildContext context}) async {
    Prefs.clear();

    ProgressDialogUtils.showProgressDialog(context);
    await Future.delayed(const Duration(seconds: 2));
    ProgressDialogUtils.dismissProgressDialog();
    // directLogout(context: context);
  }

  static void directLogout({required BuildContext context}) {
    Prefs.clear();
    pushAndRemoveUntil(
      context: context,
      widget: const MyLoginScreen(),
    );
  }

  static void pop({required BuildContext context, dynamic result}) {
    Navigator.pop(context, result);
  }

  static void push({
    required BuildContext context,
    required Widget widget,
    FutureOr<void> Function()? action,
  }) {
    Navigator.push(
      context,
      Platform.isAndroid
          ? MaterialPageRoute(builder: (context) => widget)
          : CupertinoPageRoute(builder: (context) => widget),
    ).whenComplete(() {
      if (action != null) {
        action();
      }
    });
  }

  static void pushAndRemoveUntil({
    required BuildContext context,
    required Widget widget,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      Platform.isAndroid
          ? MaterialPageRoute(builder: (context) => widget)
          : CupertinoPageRoute(builder: (context) => widget),
      (_) => false,
    );
  }
}
