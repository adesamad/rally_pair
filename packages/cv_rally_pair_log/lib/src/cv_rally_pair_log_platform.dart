import 'package:flutter/services.dart';

class CvRallyPairLogPlatform {
  const CvRallyPairLogPlatform();

  static const _channel = MethodChannel('cv_rally_pair_log/storage');

  Future<String> directoryPath() async {
    final path = await _channel.invokeMethod<String>('getLogDirectory');
    if (path == null || path.isEmpty) throw StateError('平台没有返回日志目录');
    return path;
  }
}
