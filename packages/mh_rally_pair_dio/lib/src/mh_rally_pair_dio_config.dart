import 'package:dio/dio.dart';

import 'mh_rally_pair_dio_exception.dart';
import 'mh_rally_pair_dio_response.dart';

abstract class MhRallyPairDioConfig {
  const MhRallyPairDioConfig();

  static const networkErrorCode = 500;

  BaseOptions get options => BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json;charset=UTF-8',
  );

  Future<MhRallyPairDioResponse> parseResponse(
    dynamic data, {
    required bool fullResponse,
  });

  Never handleError(DioException error) {
    throw MhRallyPairDioException(networkErrorCode, error.toString());
  }
}
