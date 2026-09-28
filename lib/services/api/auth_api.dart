import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/progress_dialog.dart';
 import 'package:flutter_nobrokeragefortenants/models/auth/auth_model.dart';
 import 'package:flutter_nobrokeragefortenants/models/dashboard/dashboard_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/api_service.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class Authapi {
  static Future<List<Map<String, dynamic>>> getBrokerOptions({
    required BuildContext context,
  }) async {
    try {
      final response = await ApiService().get(AppEndpoints.brokerOptions);
      final data = response.data is Map ? response.data['data'] : null;
      return data is List
          ? data.whereType<Map>().map((broker) => Map<String, dynamic>.from(broker)).toList()
          : <Map<String, dynamic>>[];
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<dynamic> brokerLeads({
    required BuildContext context,
    String type = 'recent',
  }) async {
    try {
      final response = await ApiService().get(
        AppEndpoints.brokerLeads,
        params: {'type': type},
      );
      return response.data;
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<DashboardModel> dashboardapi(
      {required BuildContext context, required String id}) async {
    try {
      // ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        "${AppEndpoints.dashboardapi}/$id",
        // data: data,
      );
      return DashboardModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      // ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AuthModel> editprofile(
      {required Map<String, dynamic> data,
      required BuildContext context,
      required String id}) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().put(
        "${AppEndpoints.editprofile}/$id",
        data: data,
      );
      return AuthModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AuthModel> register({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response =
          await ApiService().post(AppEndpoints.register, data: data);
      return AuthModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AuthModel> otpverify({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response =
          await ApiService().post(AppEndpoints.otpverify, data: data);
      return AuthModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AuthModel> login({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().post(AppEndpoints.login, data: data);
      return AuthModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }
}
