import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';

Alert customizedAlertDialogue({
  required BuildContext context,
  bool onWillPopActive = true,
  AlertType type = AlertType.error,
  required String desc,
  required VoidCallback onPressed,
  String buttonTitle = 'Ok',
}) {
  return Alert(
    onWillPopActive: onWillPopActive,
    closeIcon: const Text(''),
    closeFunction: () {},
    context: context,
    type: type,
    desc: desc,
    style: AlertStyle(
      descStyle: Theme.of(context)
          .textTheme
          .displayLarge!
          .copyWith(fontSize: AppFonts.size25),
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
    ),
    buttons: [
      DialogButton(
        color: AppColors.primary,
        onPressed: onPressed,
        width: 120,
        child: Text(
          buttonTitle,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ],
  );
}

void commonErrorDialogue({
  required BuildContext context,
  required String message,
}) {
  customizedAlertDialogue(
    context: context,
    desc: message,
    onPressed: () {
      Navigator.pop(context); // This will close the dialog
    },
  ).show();
}
