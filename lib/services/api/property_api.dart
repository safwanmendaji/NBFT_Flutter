import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/dialogs/progress_dialog.dart';
import 'package:flutter_nobrokeragefortenants/models/add_property/add_property_model.dart';
import 'package:flutter_nobrokeragefortenants/models/area/area_model.dart';
import 'package:flutter_nobrokeragefortenants/models/customer/customer_model.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/status_change_model.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/services/network/api_service.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class Propertyapis {
  static Future<AddPropertyModel> addpropertydetail({
    required FormData data,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().multipartPost(
        AppEndpoints.addproperty,
        data: data,
      );
      return AddPropertyModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AddPropertyModel> updatepropertydetail({
    required String propertyId,
    required FormData data,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().multipartPut(
        "${AppEndpoints.updateproperty}/$propertyId",
        data: data,
      );
      return AddPropertyModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<AreaModel> getArea({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        "${AppEndpoints.areaurl}",
        params: params,
      );
      return AreaModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<PropertiesModel> getproperties({
    required bool isShowProgress,
    required Map<String, dynamic> params,
    required String id,
    required BuildContext context,
  }) async {
    try {
      isShowProgress != true
          ? null
          : ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        "${AppEndpoints.getproperties}/$id",
        params: params,
      );
      return PropertiesModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<void> markInterest({
    required BuildContext context,
    required String propertyId,
    required String status,
  }) async {
    try {
      await ApiService().post(
        AppEndpoints.markInterest,
        data: {'propertyId': propertyId, 'status': status},
      );
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<PropertiesModel> getSharedProperties({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final query = {
        'search': '',
        'category': '',
        'floor': '',
        'priceRange': '',
        'format': '',
        'type': '',
        'furnished': '',
      };
      Response response;
      try {
        response = await ApiService().get(
          AppEndpoints.mySharedProperties,
          params: query,
        );
      } on DioException {
        response = await ApiService().get(
          "${AppEndpoints.sharedProperties}/$userId",
          params: query,
        );
      }
      final responseMap = Map<String, dynamic>.from(response.data as Map);
      final payload = responseMap['data'];
      final rawProperties =
          payload is List
              ? payload
              : payload is Map && payload['properties'] is List
              ? payload['properties'] as List
              : <dynamic>[];
      final sharedProperties =
          rawProperties
              .whereType<Map>()
              .map((item) => item['property'] ?? item['propertyId'] ?? item)
              .whereType<Map>()
              .map((property) => Map<String, dynamic>.from(property))
              .toList();
      return PropertiesModel.fromJson({
        'statusCode': responseMap['statusCode'],
        'message': responseMap['message'],
        'data': sharedProperties,
      });
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<GetCustomerModel> getcustomerdetail({
    required bool isShowProgress,
    required Map<String, dynamic> params,
    required String id,
    required BuildContext context,
  }) async {
    try {
      isShowProgress != true
          ? null
          : ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        "${AppEndpoints.customerdetail}/$id",
        params: params,
      );
      return GetCustomerModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<StatusChangeModel> changestatus({
    required BuildContext context,
    required String propertyid,
    required Map<String, dynamic> data,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().put(
        data: data,
        "${AppEndpoints.changestatus}/$propertyid",
        // data: data,
      );
      return StatusChangeModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }
}
