import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:fluttertoast/fluttertoast.dart";
 import 'package:flutter_nobrokeragefortenants/screens/auth/login/login_screen.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';

void showOkCancelAlertDialog({
  required BuildContext context,
  required String message,
  required String okButtonTitle,
  required String cancelButtonTitle,
  required Function cancelButtonAction,
  required Function okButtonAction,
  bool isCancelEnable = true,
}) {
  showDialog(
    barrierDismissible: isCancelEnable,
    context: context,
    builder: (context) {
      return Platform.isIOS
          ? _showOkCancelCupertinoAlertDialog(
              context,
              message,
              okButtonTitle,
              cancelButtonTitle,
              okButtonAction,
              isCancelEnable,
              cancelButtonAction,
            )
          : _showOkCancelMaterialAlertDialog(
              context,
              message,
              okButtonTitle,
              cancelButtonTitle,
              okButtonAction,
              isCancelEnable,
              cancelButtonAction,
            );
    },
  );
}

void showAlertDialog({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Platform.isIOS
          ? _showCupertinoAlertDialog(context, message)
          : _showMaterialAlertDialog(context, message);
    },
  );
}

CupertinoAlertDialog _showCupertinoAlertDialog(
    BuildContext context, String message) {
  return CupertinoAlertDialog(
    title: Text(
      "Radius",
      style: Theme.of(context).textTheme.displayLarge,
    ),
    content: Text(
      message,
      style: Theme.of(context).textTheme.displayMedium,
    ),
    actions: _actions(context),
  );
}

AlertDialog _showMaterialAlertDialog(BuildContext context, String message) {
  return AlertDialog(
    title: Text(
      "Radius",
      style: Theme.of(context).textTheme.displayLarge,
    ),
    content: Text(
      message,
      style: Theme.of(context).textTheme.displayMedium,
    ),
    actions: _actions(context),
  );
}

AlertDialog _showOkCancelMaterialAlertDialog(
  BuildContext context,
  String message,
  String okButtonTitle,
  String cancelButtonTitle,
  Function okButtonAction,
  bool isCancelEnable,
  Function cancelButtonAction,
) {
  return AlertDialog(
    title: Text(
      "Radius",
      style: Theme.of(context).textTheme.displayLarge,
    ),
    content: Text(
      message,
      style: Theme.of(context).textTheme.displayMedium,
    ),
    actions: _okCancelActions(
      context: context,
      okButtonTitle: okButtonTitle,
      cancelButtonTitle: cancelButtonTitle,
      okButtonAction: okButtonAction,
      isCancelEnable: isCancelEnable,
      cancelButtonAction: cancelButtonAction,
    ),
  );
}

CupertinoAlertDialog _showOkCancelCupertinoAlertDialog(
  BuildContext context,
  String message,
  String okButtonTitle,
  String cancelButtonTitle,
  Function okButtonAction,
  bool isCancelEnable,
  Function cancelButtonAction,
) {
  return CupertinoAlertDialog(
    title: Text(
      "Radius",
      style: Theme.of(context).textTheme.displayLarge,
    ),
    content: Text(
      message,
      style: Theme.of(context).textTheme.displayMedium,
    ),
    actions: isCancelEnable
        ? _okCancelActions(
            context: context,
            okButtonTitle: okButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
            okButtonAction: okButtonAction,
            isCancelEnable: isCancelEnable,
            cancelButtonAction: cancelButtonAction,
          )
        : _okAction(
            context: context,
            okButtonAction: okButtonAction,
            okButtonTitle: okButtonTitle,
          ),
  );
}

List<Widget> _actions(BuildContext context) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(
              "Ok",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : TextButton(
            child: Text(
              "Ok",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
  ];
}

List<Widget> _okCancelActions({
  required BuildContext context,
  required String okButtonTitle,
  required String cancelButtonTitle,
  required Function okButtonAction,
  required bool isCancelEnable,
  required Function cancelButtonAction,
}) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              cancelButtonAction();
            },
            child: Text(
              cancelButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              cancelButtonAction();
            },
            child: Text(
              cancelButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(
              okButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              okButtonAction();
            },
          )
        : TextButton(
            child: Text(
              okButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              okButtonAction();
            },
          ),
  ];
}

List<Widget> _okAction({
  required BuildContext context,
  required String okButtonTitle,
  required Function okButtonAction,
}) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(
              okButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              okButtonAction();
            },
          )
        : TextButton(
            child: Text(
              okButtonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              okButtonAction();
            },
          ),
  ];
}

SnackBar displaySnackBar({
  required String message,
  required BuildContext context,
}) {
  return SnackBar(
    content: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: AppColors.primary,
  );
}

Future displayToast({required String message, required BuildContext context}) {
  return Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 3,
    backgroundColor: AppColors.primary,
    textColor: AppColors.white,
    fontSize: AppFonts.size14,
  );
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppColors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 50,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          getTextWidget(
            title: 'Are you sure?',
            textFontSize: AppFonts.size18,
            textFontWeight: AppFonts.bold,
            textColor: AppColors.blackColor,
          ),
          const SizedBox(height: 10),
          getTextWidget(
            title: 'Do you really want to Logout?',
            textFontSize: AppFonts.size15,
            textFontWeight: AppFonts.medium,
            textColor: AppColors.blackColor.withOpacity(0.7),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cancel
                  },
                  child: const Text('No'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    await Prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyLoginScreen(),
                      ),
                      (route) => false,
                    );

                    // Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
