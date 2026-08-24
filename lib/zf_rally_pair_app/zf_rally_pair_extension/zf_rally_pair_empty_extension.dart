extension ZfRallyPairEmptyExtension on Object? {
  bool get isNullOrEmpty {
    final value = this;
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    return false;
  }

  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
