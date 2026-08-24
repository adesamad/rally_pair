import 'package:hive_flutter/hive_flutter.dart';

class QkRallyPairCache {
  QkRallyPairCache._();

  static const boxName = 'qk_rally_pair_cache';

  static bool _hiveInitialized = false;
  static Box<dynamic>? _box;
  static Future<Box<dynamic>>? _openingBox;
  static List<int>? _encryptionKey;

  static bool get isInitialized => _box?.isOpen == true;

  static Future<void> init({String? path, List<int>? encryptionKey}) async {
    if (encryptionKey != null && encryptionKey.length != 32) {
      throw ArgumentError.value(
        encryptionKey.length,
        'encryptionKey',
        'must contain 32 bytes',
      );
    }
    _encryptionKey = encryptionKey == null
        ? null
        : List<int>.unmodifiable(encryptionKey);
    await _openBox(path: path);
  }

  static Future<void> setString(String key, String value) async =>
      (await _openBox()).put(key, value);
  static Future<void> setBool(String key, bool value) async =>
      (await _openBox()).put(key, value);
  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    await (await _openBox()).put(key, Map<String, dynamic>.from(value));
  }

  static Future<String?> getString(String key) async {
    final value = (await _openBox()).get(key);
    return value is String ? value : null;
  }

  static Future<bool?> getBool(String key) async {
    final value = (await _openBox()).get(key);
    return value is bool ? value : null;
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    final value = (await _openBox()).get(key);
    if (value is! Map) return null;
    try {
      return Map<String, dynamic>.from(value);
    } on TypeError {
      return null;
    }
  }

  static Future<void> remove(String key) async =>
      (await _openBox()).delete(key);

  static Future<Box<dynamic>> _openBox({String? path}) {
    final opened = _box;
    if (opened?.isOpen ?? false) return Future<Box<dynamic>>.value(opened);
    return _openingBox ??= _initAndOpen(path: path);
  }

  static Future<Box<dynamic>> _initAndOpen({String? path}) async {
    try {
      if (!_hiveInitialized) {
        if (path == null) {
          await Hive.initFlutter();
        } else {
          Hive.init(path);
        }
        _hiveInitialized = true;
      }
      final key = _encryptionKey;
      final box = await Hive.openBox<dynamic>(
        boxName,
        encryptionCipher: key == null ? null : HiveAesCipher(key),
      );
      _box = box;
      return box;
    } finally {
      _openingBox = null;
    }
  }
}
