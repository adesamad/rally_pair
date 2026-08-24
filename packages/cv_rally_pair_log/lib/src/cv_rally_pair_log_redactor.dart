class CvRallyPairLogRedactor {
  const CvRallyPairLogRedactor({required this.maxMessageLength});

  final int maxMessageLength;

  static const _sensitiveKeys = <String>{
    'authorization',
    'cookie',
    'password',
    'passwd',
    'token',
    'access_token',
    'refresh_token',
    'verification_code',
    'verify_code',
  };

  String text(Object? value) {
    var result = value?.toString() ?? '';
    result = result.replaceAllMapped(
      RegExp(r'(bearer\s+)[a-z0-9\-._~+/]+=*', caseSensitive: false),
      (match) => '${match.group(1)}***',
    );
    result = result.replaceAllMapped(
      RegExp(
        r'((?:password|passwd|token|authorization)\s*[:=]\s*)[^,\s;]+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}***',
    );
    if (result.length <= maxMessageLength) return result;
    return '${result.substring(0, maxMessageLength)}…[truncated]';
  }

  Map<String, Object?> fields(Map<String, Object?> source) {
    return source.map((key, value) {
      return MapEntry(
        key,
        _sensitiveKeys.contains(key.toLowerCase()) ? '***' : _value(value),
      );
    });
  }

  Object? _value(Object? value) {
    if (value is Map) {
      return fields(value.map((key, child) => MapEntry(key.toString(), child)));
    }
    if (value is Iterable) return value.map(_value).toList(growable: false);
    if (value is String) return text(value);
    if (value is num || value is bool || value == null) return value;
    return text(value);
  }
}
