import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

const _magic = <int>[0x52, 0x50, 0x4C, 0x47];
const _version = 1;
const _noncePrefixLength = 8;
const _sequenceLength = 4;
const _tagLength = 16;
const _textHeaderPrefix = 'RPLG1:';

class CvRallyPairLogHeader {
  const CvRallyPairLogHeader({
    required this.keyId,
    required this.noncePrefix,
    required this.bytes,
  });

  final String keyId;
  final Uint8List noncePrefix;
  final Uint8List bytes;
}

class CvRallyPairDecodedLog {
  const CvRallyPairDecodedLog({
    required this.keyId,
    required this.records,
    this.warning,
  });

  final String keyId;
  final List<Map<String, dynamic>> records;
  final String? warning;
}

class CvRallyPairLogCodec {
  CvRallyPairLogCodec(String keyBase64)
    : _encrypter = Encrypter(AES(_readKey(keyBase64), mode: AESMode.gcm));

  final Encrypter _encrypter;

  CvRallyPairLogHeader createHeader(String keyId) {
    final keyIdBytes = utf8.encode(keyId);
    if (keyIdBytes.isEmpty || keyIdBytes.length > 255) {
      throw ArgumentError.value(keyId, 'keyId', 'must contain 1-255 bytes');
    }
    final noncePrefix = Uint8List.fromList(
      List<int>.generate(
        _noncePrefixLength,
        (_) => Random.secure().nextInt(256),
      ),
    );
    final bytes = BytesBuilder(copy: false)
      ..add(_magic)
      ..addByte(_version)
      ..addByte(keyIdBytes.length)
      ..add(keyIdBytes)
      ..add(noncePrefix);
    return CvRallyPairLogHeader(
      keyId: keyId,
      noncePrefix: noncePrefix,
      bytes: bytes.takeBytes(),
    );
  }

  Uint8List encode(
    CvRallyPairLogHeader header,
    int sequence,
    List<int> clearText,
  ) {
    if (sequence <= 0 || sequence > 0xFFFFFFFF) {
      throw RangeError.range(sequence, 1, 0xFFFFFFFF, 'sequence');
    }
    final sequenceBytes = _uint32(sequence);
    final nonce = Uint8List.fromList(<int>[
      ...header.noncePrefix,
      ...sequenceBytes,
    ]);
    final aad = Uint8List.fromList(<int>[...header.bytes, ...sequenceBytes]);
    final encrypted = _encrypter.encryptBytes(
      clearText,
      iv: IV(nonce),
      associatedData: aad,
    );
    final bodyLength = _sequenceLength + encrypted.bytes.length;
    return Uint8List.fromList(<int>[
      ..._uint32(bodyLength),
      ...sequenceBytes,
      ...encrypted.bytes,
    ]);
  }

  Uint8List encodeTextHeader(CvRallyPairLogHeader header) {
    return Uint8List.fromList(
      utf8.encode('$_textHeaderPrefix${base64Encode(header.bytes)}\n'),
    );
  }

  Uint8List encodeTextRecord(Uint8List record) {
    return Uint8List.fromList(utf8.encode('${base64Encode(record)}\n'));
  }

  CvRallyPairDecodedLog decodeText(String input) {
    final terminated = input.endsWith('\n');
    final lines = const LineSplitter().convert(input);
    if (lines.isEmpty || !lines.first.startsWith(_textHeaderPrefix)) {
      throw const FormatException('不是 Rally Pair 文本日志文件');
    }
    final builder = BytesBuilder(copy: false)
      ..add(base64Decode(lines.first.substring(_textHeaderPrefix.length)));
    String? warning;
    for (var index = 1; index < lines.length; index++) {
      if (index == lines.length - 1 && !terminated) {
        warning = '文件末尾存在未写完整的文本记录，已忽略';
        break;
      }
      builder.add(base64Decode(lines[index]));
    }
    final decoded = decode(builder.takeBytes());
    return CvRallyPairDecodedLog(
      keyId: decoded.keyId,
      records: decoded.records,
      warning: warning ?? decoded.warning,
    );
  }

  CvRallyPairDecodedLog decode(Uint8List input) {
    final header = readHeader(input);
    final records = <Map<String, dynamic>>[];
    var offset = header.bytes.length;
    String? warning;
    while (offset < input.length) {
      if (input.length - offset < 4) {
        warning = '文件末尾存在不完整的记录长度，已忽略';
        break;
      }
      final bodyLength = _readUint32(input, offset);
      offset += 4;
      if (bodyLength < _sequenceLength + _tagLength) {
        throw const FormatException('日志记录长度无效');
      }
      if (input.length - offset < bodyLength) {
        warning = '文件末尾存在未写完整的日志记录，已忽略';
        break;
      }
      final sequenceBytes = Uint8List.sublistView(
        input,
        offset,
        offset + _sequenceLength,
      );
      final cipherText = Uint8List.sublistView(
        input,
        offset + _sequenceLength,
        offset + bodyLength,
      );
      final nonce = Uint8List.fromList(<int>[
        ...header.noncePrefix,
        ...sequenceBytes,
      ]);
      final aad = Uint8List.fromList(<int>[...header.bytes, ...sequenceBytes]);
      final clearText = _encrypter.decryptBytes(
        Encrypted(cipherText),
        iv: IV(nonce),
        associatedData: aad,
      );
      final value = jsonDecode(utf8.decode(clearText));
      if (value is! Map) throw const FormatException('日志内容不是 JSON 对象');
      records.add(Map<String, dynamic>.from(value));
      offset += bodyLength;
    }
    return CvRallyPairDecodedLog(
      keyId: header.keyId,
      records: records,
      warning: warning,
    );
  }

  CvRallyPairLogHeader readHeader(Uint8List input) {
    const fixedLength = 6;
    if (input.length < fixedLength + _noncePrefixLength) {
      throw const FormatException('日志文件头不完整');
    }
    for (var index = 0; index < _magic.length; index++) {
      if (input[index] != _magic[index]) {
        throw const FormatException('不是 Rally Pair 日志文件');
      }
    }
    if (input[4] != _version) throw FormatException('不支持的日志版本：${input[4]}');
    final keyIdLength = input[5];
    final headerLength = fixedLength + keyIdLength + _noncePrefixLength;
    if (keyIdLength == 0 || input.length < headerLength) {
      throw const FormatException('日志文件 keyId 无效');
    }
    return CvRallyPairLogHeader(
      keyId: utf8.decode(input.sublist(6, 6 + keyIdLength)),
      noncePrefix: Uint8List.fromList(
        input.sublist(6 + keyIdLength, headerLength),
      ),
      bytes: Uint8List.fromList(input.sublist(0, headerLength)),
    );
  }

  static Key _readKey(String value) {
    final key = Key.fromBase64(value.trim());
    if (key.bytes.length != 32) {
      throw const FormatException('AES-256 密钥必须是 32 字节');
    }
    return key;
  }
}

Uint8List _uint32(int value) =>
    Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.big);

int _readUint32(Uint8List bytes, int offset) =>
    ByteData.sublistView(bytes).getUint32(offset, Endian.big);
