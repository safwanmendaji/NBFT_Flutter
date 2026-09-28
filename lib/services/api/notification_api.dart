import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/models/notifications/notification_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/api_service.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class NotificationApi {
  static Future<List<NotificationModel>> getUserNotifications({
    required BuildContext context,
  }) => _get(AppEndpoints.userNotifications, context);

  static Future<List<NotificationModel>> getBrokerNotifications({
    required BuildContext context,
  }) => _get(AppEndpoints.brokerNotifications, context);

  static Future<List<NotificationModel>> _get(
    String endpoint,
    BuildContext context,
  ) async {
    try {
      final response = await ApiService().get(endpoint);
      final payload =
          response.data is Map ? response.data['data'] : response.data;
      final rows =
          payload is Map
              ? (payload['notifications'] ?? payload['data'])
              : payload;
      if (rows is! List) return [];
      return rows
          .whereType<Map>()
          .map(
            (row) => NotificationModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }
}
