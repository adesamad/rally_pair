import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class KsRallyPairDeviceInfo {
  factory KsRallyPairDeviceInfo() => _instance;

  KsRallyPairDeviceInfo._();

  static final _instance = KsRallyPairDeviceInfo._();

  final _plugin = DeviceInfoPlugin();
  AndroidDeviceInfo? _androidInfo;
  Future<void>? _loading;

  int? get androidSdkInt => _androidInfo?.version.sdkInt;

  Future<void> init() => _loading ??= _load();

  Future<void> _load() async {
    try {
      if (Platform.isAndroid) _androidInfo = await _plugin.androidInfo;
    } catch (error) {
      debugPrint('Rally Pair device info load failed: $error');
    }
  }
}
