import 'dart:io';
import 'dart:typed_data';

import 'cv_rally_pair_log_codec.dart';

class CvRallyPairLogReadResult {
  const CvRallyPairLogReadResult({
    required this.keyId,
    required this.records,
    this.warning,
  });

  final String keyId;
  final List<Map<String, dynamic>> records;
  final String? warning;
}

class CvRallyPairLogReader {
  CvRallyPairLogReader({required String keyBase64})
    : _codec = CvRallyPairLogCodec(keyBase64);

  final CvRallyPairLogCodec _codec;

  Future<CvRallyPairLogReadResult> read(File file) async {
    return readText(await file.readAsString());
  }

  CvRallyPairLogReadResult readBytes(Uint8List bytes) =>
      readText(String.fromCharCodes(bytes));

  CvRallyPairLogReadResult readText(String text) {
    final decoded = _codec.decodeText(text);
    return CvRallyPairLogReadResult(
      keyId: decoded.keyId,
      records: decoded.records,
      warning: decoded.warning,
    );
  }
}
