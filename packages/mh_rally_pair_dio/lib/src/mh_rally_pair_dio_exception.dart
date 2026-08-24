class MhRallyPairDioException implements Exception {
  const MhRallyPairDioException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'DioException(code: $code, message: $message)';
}
