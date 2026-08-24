import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'cv_rally_pair_log_codec.dart';
import 'cv_rally_pair_log_config.dart';
import 'cv_rally_pair_log_entry.dart';
import 'cv_rally_pair_log_platform.dart';
import 'cv_rally_pair_log_redactor.dart';

class CvRallyPairLogWriter {
  CvRallyPairLogWriter(this.config)
    : _codec = CvRallyPairLogCodec(config.keyBase64),
      _redactor = CvRallyPairLogRedactor(
        maxMessageLength: config.maxMessageLength,
      );

  final CvRallyPairLogConfig config;
  final CvRallyPairLogCodec _codec;
  final CvRallyPairLogRedactor _redactor;
  final _platform = const CvRallyPairLogPlatform();

  late final Directory _directory;
  RandomAccessFile? _file;
  CvRallyPairLogHeader? _header;
  Future<void> _pending = Future<void>.value();
  int _sequence = 0;
  int _fileBytes = 0;
  bool _closed = false;

  String get directoryPath => _directory.path;

  Future<void> init() async {
    _directory = Directory(await _platform.directoryPath());
    await _directory.create(recursive: true);
    await _removeExpiredFiles();
    await _openFile();
    add(
      message: '日志目录已初始化',
      tag: 'init',
      fields: <String, Object?>{'logPath': directoryPath},
    );
    await flush();
  }

  void add({
    required Object? message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (_closed) return;
    final entry = CvRallyPairLogEntry(
      time: DateTime.now(),
      tag: tag,
      message: _redactor.text(message),
      error: error == null ? null : _redactor.text(error),
      stackTrace: stackTrace?.toString(),
      fields: _redactor.fields(fields),
    );
    if (config.consoleEnabled) {
      debugPrint(_consoleLine(entry));
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    }
    _pending = _pending.then((_) => _write(entry)).catchError((
      Object failure,
      StackTrace stack,
    ) {
      if (kDebugMode) {
        debugPrint('Rally Pair log write failed: $failure');
        debugPrintStack(stackTrace: stack);
      }
    });
  }

  Future<void> flush() async {
    await _pending;
    await _file?.flush();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await flush();
    await _file?.close();
    _file = null;
  }

  Future<List<File>> files() async {
    final entries = await _directory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.txt'))
        .cast<File>()
        .toList();
    entries.sort((left, right) => right.path.compareTo(left.path));
    return entries;
  }

  Future<void> _write(CvRallyPairLogEntry entry) async {
    var nextSequence = _sequence + 1;
    var record = _codec.encodeTextRecord(
      _codec.encode(
        _header!,
        nextSequence,
        entry.encode(sequence: nextSequence),
      ),
    );
    if (_sequence > 0 && _fileBytes + record.length > config.maxFileBytes) {
      await _rotate();
      nextSequence = 1;
      record = _codec.encodeTextRecord(
        _codec.encode(
          _header!,
          nextSequence,
          entry.encode(sequence: nextSequence),
        ),
      );
    }
    await _file!.writeFrom(record);
    await _file!.flush();
    _sequence = nextSequence;
    _fileBytes += record.length;
  }

  Future<void> _rotate() async {
    await _file?.close();
    _file = null;
    await _openFile();
    await _removeExpiredFiles();
  }

  Future<void> _openFile() async {
    final header = _codec.createHeader(config.keyId);
    final now = DateTime.now().toUtc();
    final timestamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final suffix = Random.secure()
        .nextInt(0x1000000)
        .toRadixString(16)
        .padLeft(6, '0');
    final safeAppName = config.appName.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final file = await File(
      p.join(_directory.path, '${safeAppName}_${timestamp}_$suffix.txt'),
    ).open(mode: FileMode.writeOnlyAppend);
    final textHeader = _codec.encodeTextHeader(header);
    await file.writeFrom(textHeader);
    await file.flush();
    _file = file;
    _header = header;
    _sequence = 0;
    _fileBytes = textHeader.length;
  }

  Future<void> _removeExpiredFiles() async {
    final cutoff = DateTime.now().subtract(config.retention);
    for (final file in await files()) {
      if ((await file.lastModified()).isBefore(cutoff)) await file.delete();
    }
    final retained = await files();
    for (var index = config.maxFiles; index < retained.length; index++) {
      await retained[index].delete();
    }
  }

  String _consoleLine(CvRallyPairLogEntry entry) {
    final tag = entry.tag == null ? '' : '[${entry.tag}]';
    final error = entry.error == null ? '' : ' | ${entry.error}';
    final fields = entry.fields.isEmpty ? '' : ' | ${jsonEncode(entry.fields)}';
    return '${entry.time.toIso8601String()} [$cvRallyPairLogHeader]$tag '
        '${entry.message}$error$fields';
  }
}
