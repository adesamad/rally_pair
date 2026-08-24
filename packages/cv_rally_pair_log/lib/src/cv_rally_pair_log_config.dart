class CvRallyPairLogConfig {
  const CvRallyPairLogConfig({
    required this.appName,
    required this.keyId,
    required this.keyBase64,
    this.consoleEnabled = false,
    this.maxFileBytes = 2 * 1024 * 1024,
    this.maxFiles = 8,
    this.retention = const Duration(days: 7),
    this.maxMessageLength = 8000,
  });

  final String appName;
  final String keyId;
  final String keyBase64;
  final bool consoleEnabled;
  final int maxFileBytes;
  final int maxFiles;
  final Duration retention;
  final int maxMessageLength;
}
