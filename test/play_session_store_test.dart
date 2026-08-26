import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';

void main() {
  late FdRallyPairDatabase database;
  late PlaySessionStore store;

  setUp(() {
    database = FdRallyPairDatabase(NativeDatabase.memory());
    store = PlaySessionStore(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates a draft and its courts', () async {
    final id = await store.createSession(
      const SessionDraftInput(title: ' 周三晚场 ', courtCount: 3),
    );

    final session = await store.findSession(id);

    expect(session, isNotNull);
    expect(session!.title, '周三晚场');
    expect(session.status, PlaySessionStatus.draft);
    expect(session.pairingPolicy, PairingPolicy.fairRotation);
    expect(session.scorePreset, ScorePreset.standard21);
    expect(await store.countCourts(id), 3);
  });

  test('upgrades the empty template database from schema 1', () async {
    await database.close();
    database = FdRallyPairDatabase(
      NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA user_version = 1');
        },
      ),
    );
    store = PlaySessionStore(database);

    final id = await store.createSession(
      const SessionDraftInput(title: '迁移后球局', courtCount: 2),
    );

    expect(await store.findSession(id), isNotNull);
    expect(await store.countCourts(id), 2);
  });

  test('rejects invalid draft values', () async {
    expect(
      () => store.createSession(const SessionDraftInput(title: '  ')),
      throwsA(
        isA<SessionRuleException>().having(
          (error) => error.message,
          'message',
          '请输入球局名称',
        ),
      ),
    );
    expect(
      () => store.createSession(
        const SessionDraftInput(title: '超量场地', courtCount: 9),
      ),
      throwsA(isA<SessionRuleException>()),
    );
  });

  test('adds, restores, and removes players', () async {
    final sessionId = await store.createSession(
      const SessionDraftInput(title: '周末晨练'),
    );
    final firstId = await store.addPlayer(sessionId, '  林   一  ');
    await store.addPlayer(sessionId, '陈二');

    final restoredStore = PlaySessionStore(database);
    final restored = await restoredStore.watchPlayers(sessionId).first;

    expect(restored.map((player) => player.displayName), ['林 一', '陈二']);
    expect(restored.map((player) => player.queueOrder), [0, 1]);
    expect(
      restored.every((player) => player.state == SessionPlayerState.waiting),
      isTrue,
    );

    await restoredStore.removePlayer(sessionId, firstId);
    final remaining = await restoredStore.watchPlayers(sessionId).first;
    expect(remaining.map((player) => player.displayName), ['陈二']);
  });

  test('rejects duplicate player names ignoring case and spaces', () async {
    final sessionId = await store.createSession(
      const SessionDraftInput(title: '重复名称检查'),
    );
    await store.addPlayer(sessionId, 'Alex Chen');

    expect(
      () => store.addPlayer(sessionId, '  alex   chen '),
      throwsA(
        isA<SessionRuleException>().having(
          (error) => error.message,
          'message',
          '“alex chen”已经在本场名单中',
        ),
      ),
    );
  });
}
