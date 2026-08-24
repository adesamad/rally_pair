import 'package:dio/dio.dart';

import 'mh_rally_pair_dio_client.dart';
import 'mh_rally_pair_dio_exception.dart';
import 'mh_rally_pair_dio_response.dart';

extension MhRallyPairDioRequest on MhRallyPairDioClient {
  Future<MhRallyPairDioResponse> get(
    String url, {
    Map<String, dynamic>? query,
    bool fullResponse = false,
    Options? options,
  }) => _send(
    url,
    data: query,
    method: MhRallyPairRequestMethod.get,
    fullResponse: fullResponse,
    options: options,
  );

  Future<MhRallyPairDioResponse> post(
    String url, {
    dynamic data,
    bool fullResponse = false,
    Options? options,
  }) => _send(
    url,
    data: data,
    method: MhRallyPairRequestMethod.post,
    fullResponse: fullResponse,
    options: options,
  );

  Future<MhRallyPairDioResponse> delete(
    String url, {
    dynamic data,
    bool fullResponse = false,
    Options? options,
  }) => _send(
    url,
    data: data,
    method: MhRallyPairRequestMethod.delete,
    fullResponse: fullResponse,
    options: options,
  );

  Future<MhRallyPairDioResponse> _send(
    String url, {
    required dynamic data,
    required MhRallyPairRequestMethod method,
    required bool fullResponse,
    Options? options,
  }) async {
    final parser = config;
    if (parser == null) {
      throw const MhRallyPairDioException(
        100,
        'HTTP client is not initialized',
      );
    }
    final response = await request(
      url,
      data: data,
      method: method,
      options: options,
    );
    return parser.parseResponse(response, fullResponse: fullResponse);
  }
}
