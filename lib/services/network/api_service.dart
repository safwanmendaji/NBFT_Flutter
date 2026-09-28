import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/loggers.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/app_navigator.dart';
 import 'package:flutter_nobrokeragefortenants/screens/user/subscription_screen.dart';
 import 'package:flutter_nobrokeragefortenants/services/subscription_gate.dart';

class ApiService {
  static final Dio _dio = _initializeDio();

  static final BaseOptions _options = BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    baseUrl: AppEndpoints.baseUrl, // put your base url here
    contentType: 'application/json',
  );

  static Dio _initializeDio() {
    final dio = Dio(_options);
    dio.interceptors.add(_createInterceptors());
    return dio;
  }

  static InterceptorsWrapper _createInterceptors() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll({
          'Authorization': "Bearer ${Prefs.getString(LocalStrings.usertoken)}",
          // Prefs.getString(LocalStrings.selectlanguage),
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS, GET,PUT',
          'Access-Control-Allow-Credentials': 'true',
        });
        Logger.logError(message: options.headers.toString(), name: "Headers");
        Logger.logError(
          message: options.baseUrl.toString() + options.path,
          name: "BaseURL",
        );
        Logger.logError(
          message: options.queryParameters.toString(),
          name: "QueryParam",
        );
        Logger.logError(message: options.data.toString(), name: "Data");
        handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.logError(message: response.statusCode.toString(), name: "Code");
        Logger.logError(message: response.toString(), name: "Response");
        handler.next(response);
      },
      onError: (error, handler) {
        Logger.logError(message: error.error.toString(), name: "Error");
        Logger.logError(message: error.response.toString(), name: "Error Data");
        if (error.type == DioExceptionType.connectionTimeout) {
          // Handle connection timeout
        }
        final responseData = error.response?.data;
        final requiresSubscription =
            error.response?.statusCode == 403 &&
            responseData is Map &&
            responseData['code'] == 'SUBSCRIPTION_REQUIRED';
        if (requiresSubscription && SubscriptionGate.isUser) {
          final navigator = appNavigatorKey.currentState;
          if (navigator != null) {
            Future.microtask(() {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                (_) => false,
              );
            });
          }
        }
        handler.next(error);
      },
    );
  }

  Future<Response> delete(
    String endUrl, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? params,
  }) async {
    return _performRequest(
      () => _dio.delete(endUrl, data: data, queryParameters: params),
    );
  }

  Future<dynamic> get(String endUrl, {Map<String, dynamic>? params}) async {
    return _performRequest(() => _dio.get(endUrl, queryParameters: params));
  }

  Future<Response> multipartPost(
    String endUrl, {
    required FormData data,
  }) async {
    return _performRequest(() => _dio.post(endUrl, data: data));
  }

  Future<Response> multipartPut(String endUrl, {required FormData data}) async {
    return _performRequest(() => _dio.put(endUrl, data: data));
  }

  Future<dynamic> post(
    String endUrl, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    return _performRequest(
      () => _dio.post(endUrl, data: data, queryParameters: params),
    );
  }

  Future<dynamic> put(
    String endUrl, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    return _performRequest(
      () => _dio.put(endUrl, data: data, queryParameters: params),
    );
  }

  Future<T> _performRequest<T>(Future<T> Function() request) async {
    if (!await checkUserConnection()) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
        error: 'Network Slow',
      );
    }
    try {
      return await request();
    } catch (e) {
      rethrow;
    }
  }
}
