import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/repositories/visits_repository.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/api_service.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class VisitApi implements VisitsRepository {
  VisitApi(this.context);

  final BuildContext context;

  @override
  Future<List<VisitModel>> getVisits({required bool isBroker}) => _get(
    isBroker ? AppEndpoints.brokerVisits : AppEndpoints.userVisits,
  );

  @override
  Future<void> confirmVisit(String visitId) =>
      _put(AppEndpoints.confirmVisit(visitId));

  @override
  Future<void> cancelVisit(String visitId) =>
      _put(AppEndpoints.cancelVisit(visitId));

  Future<List<VisitModel>> _get(String endpoint) async {
    try {
      final response = await ApiService().get(endpoint);
      final payload =
          response.data is Map ? response.data['data'] : response.data;
      final rows =
          payload is Map ? (payload['visits'] ?? payload['data']) : payload;
      if (rows is! List) return [];
      return rows
          .whereType<Map>()
          .map((row) => VisitModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }

  Future<void> _put(String endpoint) async {
    try {
      await ApiService().put(endpoint);
    } on DioException catch (error) {
      throw ErrorManager().handleError(e: error, context: context);
    }
  }
}
