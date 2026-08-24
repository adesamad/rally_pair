import 'dart:convert';

import 'package:cv_rally_pair_log/cv_rally_pair_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/rally_pair_widgets/rt_rally_pair_input/rt_rally_pair_input.dart';
import 'package:rally_pair/us_rally_pair_dio/us_rally_pair_dio.dart';

void main() {
  test('network config parses standard response envelopes', () async {
    const config = UsRallyPairHttpConfig(baseUrl: 'https://example.invalid');
    final response = await config.parseResponse(<String, dynamic>{
      'code': 200,
      'data': <String, dynamic>{'ready': true},
      'msg': 'ok',
    }, fullResponse: false);

    expect(response.success, isTrue);
    expect(response.code, 200);
    expect(response.data, <String, dynamic>{'ready': true});
  });

  test('log codec round-trips encrypted text records', () {
    const key = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
    final codec = CvRallyPairLogCodec(key);
    final header = codec.createHeader('test-key');
    final record = codec.encode(header, 1, utf8.encode('{"ready":true}'));
    final text = utf8.decode(<int>[
      ...codec.encodeTextHeader(header),
      ...codec.encodeTextRecord(record),
    ]);

    final decoded = codec.decodeText(text);
    expect(decoded.keyId, 'test-key');
    expect(decoded.records.single['ready'], isTrue);
  });

  testWidgets('input field does not dispose an external controller', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'before');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RtRallyPairInputField(controller: controller)),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());

    controller.text = 'after';
    expect(controller.text, 'after');
    controller.dispose();
  });
}
