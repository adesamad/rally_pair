import 'dart:io';

import 'package:flutter/foundation.dart';

import 'cv_rally_pair_log_config.dart';
import 'cv_rally_pair_log_writer.dart';

class CvRallyPairLog {
  CvRallyPairLog._();

  static CvRallyPairLogWriter? _writer;
  static FlutterExceptionHandler? _previousFlutterError;
  static bool Function(Object, StackTrace)? _previousPlatformError;

  static bool get isInitialized => _writer != null;
  static String? get directoryPath => _writer?.directoryPath;

  static Future<void> init(CvRallyPairLogConfig config) async {
    await _writer?.close();
    final writer = CvRallyPairLogWriter(config);
    await writer.init();
    _writer = writer;
  }

  static void installErrorHandlers() {
    _previousFlutterError ??= FlutterError.onError;
    FlutterError.onError = (details) {
      log(
        details.exceptionAsString(),
        tag: 'flutter',
        error: details.exception,
        stackTrace: details.stack,
        fields: <String, Object?>{
          if (details.library != null) 'library': details.library,
          if (details.context != null) 'context': details.context.toString(),
        },
      );
      final previous = _previousFlutterError;
      if (previous != null) {
        previous(details);
      } else {
        FlutterError.presentError(details);
      }
    };
    _previousPlatformError ??= PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      log(error, tag: 'platform', error: error, stackTrace: stack);
      return _previousPlatformError?.call(error, stack) ?? false;
    };
  }

  static void log(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    _writer?.add(
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  static Future<void> flush() async => _writer?.flush();

  static Future<void> close() async {
    final writer = _writer;
    _writer = null;
    await writer?.close();
  }

  static Future<List<File>> files() async => _writer?.files() ?? const <File>[];
}
