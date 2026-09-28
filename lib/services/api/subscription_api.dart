import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/models/subscription/subscription_model.dart';
 import 'package:flutter_nobrokeragefortenants/models/subscription/requirement_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/api_service.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class SubscriptionApi {
  static Future<UserRequirement?> getRequirement({
    required BuildContext context,
  }) async {
    try {
      final response = await ApiService().get(AppEndpoints.getRequirementForm);
      if (response.data is! Map) return null;
      final responseMap = Map<String, dynamic>.from(response.data as Map);
      final payload = responseMap['data'] ?? responseMap['requirement'];
      if (payload is List) {
        if (payload.isEmpty || payload.first is! Map) return null;
        return UserRequirement.fromJson(
          Map<String, dynamic>.from(payload.first),
        );
      }
      if (payload is Map) {
        final requirement = Map<String, dynamic>.from(payload);
        final hasRequirementFields = requirement.keys.any(
          (key) => const {
            '_id',
            'id',
            'propertyPurpose',
            'propertyType',
            'state',
            'city',
            'area',
            'size',
            'priceRange',
          }.contains(key),
        );
        return hasRequirementFields
            ? UserRequirement.fromJson(requirement)
            : null;
      }
      return null;
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<dynamic> submitRequirement({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiService().post(
        AppEndpoints.requirementForm,
        data: data,
      );
      return response.data;
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<dynamic> updateRequirement({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiService().put(
        '${AppEndpoints.updateRequirement}/$id',
        data: data,
      );
      return response.data;
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<SubscriptionStatus> getMySubscription({
    required BuildContext context,
  }) async {
    try {
      final response = await ApiService().get(AppEndpoints.mySubscription);
      if (response.data is! Map) {
        return const SubscriptionStatus(isRefunded: false);
      }
      final responseMap = Map<String, dynamic>.from(response.data as Map);
      final payload =
          responseMap['data'] is Map
              ? Map<String, dynamic>.from(responseMap['data'])
              : responseMap;
      return SubscriptionStatus.fromJson(payload);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<Map<String, dynamic>> createPaymentOrder({
    required BuildContext context,
    required int amount,
    required String requirementId,
  }) async {
    try {
      final response = await ApiService().post(
        AppEndpoints.createPaymentOrder,
        data: {'amount': amount, 'requirementId': requirementId},
      );
      final responseMap = Map<String, dynamic>.from(response.data as Map);
      return Map<String, dynamic>.from(responseMap['data'] as Map);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  static Future<SubscriptionStatus> verifyPayment({
    required BuildContext context,
    required String requirementId,
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount,
  }) async {
    try {
      final response = await ApiService().post(
        AppEndpoints.verifyPayment,
        data: {
          'requirementId': requirementId,
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'amountPaid': amount,
        },
      );
      final responseMap = Map<String, dynamic>.from(response.data as Map);
      final payload = Map<String, dynamic>.from(responseMap['data'] as Map);
      return SubscriptionStatus.fromJson(payload);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }
}
