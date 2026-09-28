import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

 import 'package:flutter_nobrokeragefortenants/core/dialogs/dialogue.dart';
import 'package:flutter_nobrokeragefortenants/services/media/permission_service.dart';

Future<File?> getImage(
  camera,
  int index, {
  required ImageSource source,
  required BuildContext context,
}) async {
  File? file;
  final picker = ImagePicker();
  try {
    if (source == ImageSource.camera) {
      bool isCamera = await requestPermission(permission: Permission.camera);
      if (isCamera) {
        final pickedFile =
            await picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      } else {
        if (!context.mounted) return file;
        showOkCancelAlertDialog(
          context: context,
          message: "",
          // AppLocalizations.of(context)!.imagepermission,
          okButtonTitle: "Settings",
          // AppLocalizations.of(context)!.settingsstring,
          cancelButtonTitle: "cancel",
          // AppLocalizations.of(context)!.cancel,
          okButtonAction: () {
            AppSettings.openAppSettings();
          },
          cancelButtonAction: () {},
        );
      }
    } else {
      if (Platform.isIOS) {
        bool isPhoto = await requestPermission(permission: Permission.photos);
        if (isPhoto) {
          final pickedFile =
              await picker.pickImage(source: source, imageQuality: 50);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
        } else {
          if (!context.mounted) return file;
          showOkCancelAlertDialog(
            context: context,
            message: "",
            // AppLocalizations.of(context)!.imagepermission,
            okButtonTitle: "Settings",
            //  AppLocalizations.of(context)!.settingsstring,
            cancelButtonTitle: "Cancel",
            // AppLocalizations.of(context)!.cancel,
            okButtonAction: () {
              AppSettings.openAppSettings();
            },
            cancelButtonAction: () {},
          );
        }
      } else {
        final pickedFile =
            await picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return file;
}

Future<File?> getVideo({
  required ImageSource source,
  required BuildContext context,
  required bool mounted,
}) async {
  File? file;
  final picker = ImagePicker();
  try {
    if (source == ImageSource.camera) {
      bool isCamera = await requestPermission(permission: Permission.camera);
      if (isCamera) {
        final pickedFile =
            await picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      } else {
        if (!context.mounted) return file;
        showOkCancelAlertDialog(
          context: context,
          message: "",
          // AppLocalizations.of(context)!.imagepermission,
          okButtonTitle: "Settings",
          //  AppLocalizations.of(context)!.settingsstring,
          cancelButtonTitle: "Cancel",
          // AppLocalizations.of(context)!.cancel,
          okButtonAction: () {
            AppSettings.openAppSettings();
          },
          cancelButtonAction: () {},
        );
      }
    } else {
      if (Platform.isIOS) {
        bool isPhoto = await requestPermission(permission: Permission.photos);
        if (isPhoto) {
          final pickedFile =
              await picker.pickImage(source: source, imageQuality: 50);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
        } else {
          if (!context.mounted) return file;
          showOkCancelAlertDialog(
            context: context,
            message: "",
            // AppLocalizations.of(context)!.imagepermission,
            okButtonTitle: "Settings",
            //  AppLocalizations.of(context)!.settingsstring,
            cancelButtonTitle: "Cancel",
            okButtonAction: () {
              AppSettings.openAppSettings();
            },
            cancelButtonAction: () {},
          );
        }
      } else {
        final pickedFile =
            await picker.pickImage(source: source, imageQuality: 50);
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return file;
}
