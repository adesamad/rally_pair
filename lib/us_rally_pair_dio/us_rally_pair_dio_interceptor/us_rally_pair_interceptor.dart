import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mh_rally_pair_dio/mh_rally_pair_dio.dart';

class UsRallyPairInterceptor extends Interceptor {
  const UsRallyPairInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll(<String, dynamic>{
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'random': Random.secure().nextInt(1000000),
      'deviceInfo': defaultTargetPlatform.name,
    });
    handler.next(options);
  }
}
