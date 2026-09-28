import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

 import 'package:flutter_nobrokeragefortenants/models/local_success_model.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/dialogue.dart';

class ErrorManager {
  LocalSuccesModel handleError({
    required dynamic e,
    required BuildContext context,
  }) {
    // print(e);
    // log(e.toString(), name: "Error");
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 401) {
          return LocalSuccesModel(
            status: 0,
            message: e.response?.data['message'] ?? "",
            // AppLocalizations.of(context)!.sessionexpired,
          );
        } else if (statusCode == 501) {
          return LocalSuccesModel(
            status: 1,
            message: e.response?.data['message'] ?? "",
            //  AppLocalizations.of(context)!.somethingwrong,
          );
        } else if (statusCode == 422) {
          return LocalSuccesModel(
            status: 1,
            message: e.response?.data['message'] ?? "",
            // AppLocalizations.of(context)!.somethingwrong,
          );
        } else if (statusCode == 400) {
          return LocalSuccesModel(
            status: 1,
            message: e.response?.data['message'] ?? "",
            // e.response?.data['message'] ??
            //     AppLocalizations.of(context)!.somethingwrong,
          );
        } else if (statusCode == 404) {
          return LocalSuccesModel(
            status: 4, // New custom status for "No data found"
            message: e.response?.data['message'] ?? "No data found",
          );
        } else {
          return LocalSuccesModel(
            status: 2,
            message: e.response?.data['message'] ?? "",
            // e.response?.data?['message'] ??
            //     AppLocalizations.of(context)!.somethingwrong,
          );
        }
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return LocalSuccesModel(
          status: 3,
          message: e.response?.data['message'] ?? "",
          //  AppLocalizations.of(context)!.slowinternet,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return LocalSuccesModel(
          status: 3,
          message: e.response?.data['message'] ?? "",
          //  AppLocalizations.of(context)!.nointernet,
        );
      } else {
        return LocalSuccesModel(
          status: 2,
          message: e.response?.data['message'] ?? "",
          // AppLocalizations.of(context)!.somethingwrong,
        );
      }
    } else {
      return LocalSuccesModel(
        status: 2,
        message: e.response?.data['message'] ?? "",
        //  AppLocalizations.of(context)!.somethingwrong,
      );
    }
  }

  showErrorDialogue({required dynamic e, required BuildContext context}) {
    if (e is LocalSuccesModel) {
      switch (e.status) {
        case 0:
          customizedAlertDialogue(
            context: context,
            desc: e.message ?? '',
            onPressed: () {
              Alert(context: context).dismiss();
            },
          ).show();
          break;
        case 1:
          customizedAlertDialogue(
            context: context,
            desc: e.message ?? '',
            onPressed: () {
              Alert(context: context).dismiss();
            },
          ).show();
          break;
        case 2:
          customizedAlertDialogue(
            context: context,
            desc: e.message ?? "",
            onPressed: () {
              Alert(context: context).dismiss();
            },
          ).show();
          break;
        case 3:
          displayToast(message: e.message ?? '', context: context);
          // displayToast(e.message??'');
          break;
        case 4:
          log("404 Error :- ${e.message ?? '404 Error '}");
          displayToast(message: e.message ?? '', context: context);
          break;
        default:
          customizedAlertDialogue(
            context: context,
            desc: e.message ?? '',
            onPressed: () {
              Alert(context: context).dismiss();
            },
          ).show();
          break;
      }
    } else {
      debugPrint(e.toString());
    }
  }

  // LocalSuccesModel handleError({dynamic e, required BuildContext context}) {
  //   Logger.logError(message: e, name: "handle_error");
  //   if (e is DioException) {
  //     switch (e.type) {
  //       case DioExceptionType.badResponse:
  //         // print(e);
  //         final statusCode = e.response?.statusCode;
  //         return LocalSuccesModel(
  //           status: _mapStatusCodeToStatus(statusCode: statusCode),
  //           message: _mapStatusCodeToMessage(
  //               e: e, statusCode: statusCode, context: context),
  //         );
  //       case DioExceptionType.receiveTimeout:
  //         return LocalSuccesModel(
  //           status: 3,
  //           message: AppLocalizations.of(context)!.slowinternet,
  //           //  "Poor Internet Connection.",
  //         );
  //       case DioExceptionType.connectionError:
  //         return LocalSuccesModel(
  //           status: 3,
  //           message: AppLocalizations.of(context)!.nointernet,
  //           // "No internet connection. Please check your internet connection.",
  //         );
  //       case DioExceptionType.unknown:
  //         return LocalSuccesModel(
  //           status: 2,
  //           message: AppLocalizations.of(context)!.somethingwrong,
  //           // "Something went wrong",
  //         );
  //       default:
  //         return LocalSuccesModel(
  //           status: 2,
  //           message: AppLocalizations.of(context)!.somethingwrong,
  //           // "Something went wrong",
  //         );
  //     }
  //   } else {
  //     return LocalSuccesModel(
  //       status: 2,
  //       message: AppLocalizations.of(context)!.somethingwrong,
  //       //  "Something went wrong",
  //     );
  //   }
  // }

  // int _mapStatusCodeToStatus({int? statusCode}) {
  //   switch (statusCode) {
  //     case 401:
  //       return 0;
  //     case 501:
  //       return 2;
  //     case 422:
  //       return 1;
  //     default:
  //       return 2;
  //   }
  // }

  // String _mapStatusCodeToMessage(
  //     {required DioException e,
  //     int? statusCode,
  //     required BuildContext context}) {
  //   switch (statusCode) {
  //     case 401:
  //       return AppLocalizations.of(context)!.sessionexpired;
  //     // "Your session has expired. Please log in again.";
  //     case 501:
  //       return AppLocalizations.of(context)!.somethingwrong;
  //     // "Something went wrong";
  //     case 422:
  //       return e.response?.data['message'] ??
  //           AppLocalizations.of(context)!.somethingwrong;
  //     // "Something went wrong";
  //     default:
  //       return AppLocalizations.of(context)!.somethingwrong;
  //     // "Something went wrong";
  //   }
  // }

  // void showErrorDialogue({
  //   required dynamic e,
  //   required BuildContext context,
  // }) {
  //   if (e is LocalSuccesModel) {
  //     switch (e.status) {
  //       case 0:
  //         _showAlertDialogue(
  //             context: context,
  //             message: e.message ?? '',
  //             onPressed: () {
  //               NavigationUtils.directLogout(context: context);
  //               // pop(context: context);
  //               // NavigationUtils.pop(context: context);
  //             });
  //         break;
  //       case 1:
  //         _showAlertDialogue(
  //             context: context,
  //             message: e.message ?? "",
  //             onPressed: () {
  //               NavigationUtils.pop(context: context);
  //             });
  //       case 2:
  //         _showAlertDialogue(
  //             context: context,
  //             message: e.message ?? "",
  //             onPressed: () {
  //               NavigationUtils.pop(context: context);
  //             });
  //         break;
  //       case 3:
  //         displayToast(message: e.message ?? "", context: context);
  //         break;
  //       default:
  //         _showAlertDialogue(
  //             context: context,
  //             message: e.message ?? "",
  //             onPressed: () {
  //               NavigationUtils.pop(context: context);
  //             });
  //         break;
  //     }
  //   } else {
  //     // print(e);
  //     debugPrint(e.toString());
  //   }
  // }

  // void _showAlertDialogue({
  //   required BuildContext context,
  //   required String message,
  //   required VoidCallback onPressed,
  //   // required void Function() onPressed,
  // }) {
  //   customizedAlertDialogue(
  //     context: context,
  //     desc: message,
  //     onPressed: onPressed,
  //   ).show();
  // }
}

// // Usage
// final errorManager = ErrorManager();

// void handleErrorAndShowDialogue({
//   required dynamic error,
//   required BuildContext context,
// }) {
//   final localSuccessModel = errorManager.handleError(error);
//   errorManager.showErrorDialogue(e: localSuccessModel, context: context);
// }
