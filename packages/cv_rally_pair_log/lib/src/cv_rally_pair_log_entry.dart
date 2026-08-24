import 'dart:convert';

const cvRallyPairLogHeader = 'RALLY_PAIR_LOG';

class CvRallyPairLogEntry {
  const CvRallyPairLogEntry({
    required this.time,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
    this.fields = const <String, Object?>{},
  });

  final DateTime time;
  final String message;
  final String? tag;
  final String? error;
  final String? stackTrace;
  final Map<String, Object?> fields;

  List<int> encode({required int sequence}) => utf8.encode(
    jsonEncode(<String, Object?>{
      'sequence': sequence,
      'time': time.toIso8601String(),
      'header': cvRallyPairLogHeader,
      if (tag != null && tag!.isNotEmpty) 'tag': tag,
      'message': message,
      if (error != null && error!.isNotEmpty) 'error': error,
      if (stackTrace != null && stackTrace!.isNotEmpty)
        'stackTrace': stackTrace,
      if (fields.isNotEmpty) 'fields': fields,
    }),
  );
}
