import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'mh_rally_pair_dio_config.dart';
import 'mh_rally_pair_dio_exception.dart';

enum MhRallyPairRequestMethod { get, post, delete }

class MhRallyPairDioClient {
  factory MhRallyPairDioClient() => _instance;

  MhRallyPairDioClient._();

  static final _instance = MhRallyPairDioClient._();

  Dio? _dio;
  MhRallyPairDioConfig? _config;
  final _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    error: true,
  );

  MhRallyPairDioConfig? get config => _config;

  Future<void> init(
    MhRallyPairDioConfig config, {
    bool debugLog = false,
    String? proxy,
  }) async {
    _config = config;
    final dio = Dio(config.options);
    if (debugLog) dio.interceptors.add(_logger);
    if (kDebugMode && proxy != null && proxy.trim().isNotEmpty) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (_) => 'PROXY $proxy';
        client.badCertificateCallback = (certificate, host, port) => true;
        return client;
      };
    }
    _dio = dio;
  }

  void addInterceptors(Iterable<Interceptor> interceptors) {
    final dio = _requireDio();
    final logsLast = dio.interceptors.remove(_logger);
    dio.interceptors.addAll(interceptors);
    if (logsLast) dio.interceptors.add(_logger);
  }

  Future<dynamic> request(
    String url, {
    dynamic data,
    MhRallyPairRequestMethod method = MhRallyPairRequestMethod.get,
    Options? options,
  }) async {
    final dio = _requireDio();
    try {
      final response = switch (method) {
        MhRallyPairRequestMethod.get => await dio.get<dynamic>(
          url,
          queryParameters: data as Map<String, dynamic>?,
          options: options,
        ),
        MhRallyPairRequestMethod.post => await dio.post<dynamic>(
          url,
          data: data,
          options: options,
        ),
        MhRallyPairRequestMethod.delete => await dio.delete<dynamic>(
          url,
          data: data,
          options: options,
        ),
      };
      return response.data;
    } on DioException catch (error) {
      _config!.handleError(error);
    }
  }

  Dio _requireDio() {
    final dio = _dio;
    if (dio == null || _config == null) {
      throw const MhRallyPairDioException(
        100,
        'HTTP client is not initialized',
      );
    }
    return dio;
  }
}
