import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/dialogs/progress_dialog.dart';
import 'package:flutter_nobrokeragefortenants/models/add_property/add_property_model.dart';
import 'package:flutter_nobrokeragefortenants/models/area/area_model.dart';
import 'package:flutter_nobrokeragefortenants/models/customer/customer_model.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/status_change_model.dart';
import 'package:flutter_nobrokeragefortenants/models/visits/schedule_visit_model.dart';
import 'package:flutter_nobrokeragefortenants/models/visits/visit_availability_model.dart';
import 'package:flutter_nobrokeragefortenants/models/subscription/my_subscription_model.dart';
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
  static Future<PropertiesModel> getAllProperties({required bool isShowProgress, required Map<String, dynamic> params, required String id, required BuildContext context}) async {
    try {
      isShowProgress != true ? null : ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(AppEndpoints.myproperties, params: params);
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
    required Map<String, dynamic> params,
  }) async {
    try {

      Response response;
      try {
        response = await ApiService().get(
          AppEndpoints.mySharedProperties,
          params: params,
        );
      } on DioException {
        response = await ApiService().get(
          "${AppEndpoints.sharedProperties}/$userId",
          params: params,
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

  static Future<VisitAvailabilityModel> getVisitAvailability({
    required bool isShowProgress,
    required String propertyId,
    required String date,
    required BuildContext context,
  }) async {
    try {
      isShowProgress != true ? null : ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        AppEndpoints.visitAvailability(propertyId,date)
      );
      return VisitAvailabilityModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<ScheduleVisitModel> scheduleVisit({
    required BuildContext context,
    required String propertyId,
    required String visitDate,
    required String startTime,
    required String endTime,
    required bool isShowProgress,
  }) async {
    try {
      isShowProgress != true ? null : ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().post(
        AppEndpoints.scheduleVisit,
        data: {
          'propertyId': propertyId,
          'visitDate': visitDate,
          'startTime': startTime,
          'endTime': endTime,
        },
      );
      return ScheduleVisitModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }

  static Future<void> toggleInterest({
    required BuildContext context,
    required String propertyId,
    required String interested,
  }) async {
    try {
      await ApiService().post(
        AppEndpoints.toggleInterest,
        data: {
          'propertyId': propertyId,
          'status': interested,
        },
      );
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<MySubscriptionModel>  getMySubscription({
    required BuildContext context,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      final response = await ApiService().get(
        AppEndpoints.mysubscription,
      );
      return MySubscriptionModel.fromJson(response.data);
    } on DioException catch (error) {
      //rethrow;
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<PropertiesModel> searchProperty({
    required BuildContext context,
    String? category,
    String? floor,
    String? priceRange,
    String? format,
    String? type,
    String? furnished,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);

      //shareproperty/getproperties/6a6b19bc69e56532c900d482?search=S&category=&floor=&priceRange=&format=&type=&furnished=
      final response = await ApiService().post(
        AppEndpoints.searchProperty,
        params: {
          'category': category ?? '',
          'floor': floor ?? '',
          'priceRange': priceRange ?? '',
          'format': format ?? '',
          'type': type ?? '',
          'furnished': furnished ?? '',
        },
      );

      return PropertiesModel.fromJson(response.data);
    } on DioException catch (error) {
      throw ErrorManager().handleError(
        e: error,
        context: context,
      );
    }

  }

  static Future<StatusChangeModel> managePropertyStatus({
    required BuildContext context,
    required String propertyId,
    required String action,
  }) async {
    try {
      ProgressDialogUtils.showProgressDialog(context);
      
      if (action == 'delete') {
        final response = await ApiService().delete(
          AppEndpoints.deleteproperty(propertyId),
          data: {},
        );
        return StatusChangeModel.fromJson(response.data);
      } else {
        final response = await ApiService().put(
          "${AppEndpoints.changestatus}/$propertyId",
          data: {'status': action,"remark":"Looks Good"},
        );
        return StatusChangeModel.fromJson(response.data);
      }
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    } finally {
      ProgressDialogUtils.dismissProgressDialog();
    }
  }
}


