import 'dart:convert';

import 'package:mh_rally_pair_dio/mh_rally_pair_dio.dart';

import '../us_rally_pair_dio_interceptor/us_rally_pair_interceptor.dart';

class UsRallyPairHttpConfig extends MhRallyPairDioConfig {
  const UsRallyPairHttpConfig({required this.baseUrl});

  final String baseUrl;

  static const logicErrorCode = 400;

  @override
  BaseOptions get options => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json;charset=UTF-8',
  );

  @override
  Future<MhRallyPairDioResponse> parseResponse(
    dynamic data, {
    required bool fullResponse,
  }) async {
    if (fullResponse) {
      return MhRallyPairDioResponse(success: true, code: 200, data: data);
    }

    dynamic decoded = data;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } on FormatException catch (error) {
        throw MhRallyPairDioException(logicErrorCode, error.toString());
      }
    }
    if (decoded is! Map) {
      return const MhRallyPairDioResponse(
        success: false,
        code: logicErrorCode,
        message: 'Response is not a JSON object',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    final code = map['code'] as int?;
    return MhRallyPairDioResponse(
      success: code == 0 || code == 200,
      code: code,
      data: map['data'],
      message: (map['message'] ?? map['msg']) as String?,
    );
  }
}

Future<MhRallyPairDioClient> initUsRallyPairHttp({
  required String baseUrl,
  bool debugLog = false,
  String? proxy,
  Iterable<Interceptor> interceptors = const <Interceptor>[],
}) async {
  final client = MhRallyPairDioClient();
  await client.init(
    UsRallyPairHttpConfig(baseUrl: baseUrl),
    debugLog: debugLog,
    proxy: proxy,
  );
  client.addInterceptors(<Interceptor>[
    const UsRallyPairInterceptor(),
    ...interceptors,
  ]);
  return client;
}
