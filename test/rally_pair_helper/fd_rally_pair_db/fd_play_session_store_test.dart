import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_db.dart';

void main() {
  late FdRallyPairDatabase database;
  late FdPlaySessionStore store;

  setUp(() {
    database = FdRallyPairDatabase(NativeDatabase.memory());
    store = FdPlaySessionStore(database);
  });

  tearDown(() => database.close());

  test('round-trip 保留双人组、具体场地和待轮转状态', () async {
    final session = _session();
    final match = session.assignNextGroups(1);
    session.startMatch(match.id);
    session.finishMatch(match.id, MatchResult.winnerOnly(Side.b));

    await store.save(session);
    final restored = await store.load(session.id);

    expect(restored, isNotNull);
    expect(restored!.groups, hasLength(3));
    expect(restored.courts.single.name, '1 号场');
    expect(restored.courts.single.state, CourtState.awaitingRotation);
    expect(restored.matches.single.state, MatchState.resultRecorded);
  });

  test('update 在同一事务中保存轮转后的下一场', () async {
    final session = _session();
    final match = session.assignNextGroups(1);
    session.startMatch(match.id);
    session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));
    await store.save(session);

    final updated = await store.update(
      session.id,
      (value) => value.resolveWinnerStays(match.id),
    );

    expect(updated.matches, hasLength(2));
    expect(updated.matches.first.state, MatchState.completed);
    expect(updated.matches.last.state, MatchState.ready);
    expect((await store.load(session.id))!.matches, hasLength(2));
  });

  test('round-trip 保留单打形式、个人候场和留场球友', () async {
    final session = PlaySession.create(
      id: 30,
      setup: const SessionSetup(
        title: '单打持久化',
        courtCount: 1,
        matchFormat: MatchFormat.singles,
        scorePreset: ScorePreset.standard21,
        randomSeed: 30,
      ),
    );
    for (var index = 1; index <= 2; index++) {
      session.addPlayer('单打$index');
    }
    session.start();
    final match = session.assignNext(1);
    session.startMatch(match.id);
    session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));
    session.resolveWinnerStays(match.id);

    await store.save(session);
    final restored = (await store.load(session.id))!;

    expect(restored.setup.matchFormat, MatchFormat.singles);
    expect(restored.setup.singleGame, isTrue);
    expect(restored.groups, isEmpty);
    expect(restored.courts.single.stayingPlayerId, 1);
    expect(restored.matches.single.teamA.second, isNull);
  });

  test('delete 删除聚合全部 owned rows', () async {
    final session = _session();
    await store.save(session);

    await store.delete(session.id);

    expect(await store.load(session.id), isNull);
    expect(await database.select(database.sessionGroupRecords).get(), isEmpty);
    expect(await database.select(database.sessionPlayerRecords).get(), isEmpty);
  });

  test('replaceAll 原子清除旧聚合并写入测试聚合', () async {
    await store.save(_session());
    final replacement = PlaySession.create(
      id: 10,
      setup: const SessionSetup(
        title: '替换后的测试球局',
        courtCount: 1,
        scorePreset: ScorePreset.quick11,
        randomSeed: 10,
      ),
    )..addPlayer('测试玩家');

    await store.replaceAll([replacement]);

    expect(await store.load(9), isNull);
    expect((await store.loadAll()).single.id, 10);
    expect(
      (await database.select(database.sessionPlayerRecords).get()).single.name,
      '测试玩家',
    );
  });

  test('schema v3 活动可非破坏升级并继续读取', () async {
    await database.close();
    database = FdRallyPairDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute('''
            CREATE TABLE play_session_records (
              id INTEGER NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              court_count INTEGER NOT NULL,
              pairing_policy TEXT NOT NULL,
              score_preset TEXT NOT NULL,
              avoid_recent_partner INTEGER NOT NULL,
              random_seed INTEGER NOT NULL,
              status TEXT NOT NULL,
              next_player_id INTEGER NOT NULL,
              next_match_id INTEGER NOT NULL,
              next_queue_order INTEGER NOT NULL,
              pairing_round INTEGER NOT NULL,
              completion_order INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          sqlite.execute('''
            CREATE TABLE session_player_records (
              session_id INTEGER NOT NULL,
              id INTEGER NOT NULL,
              name TEXT NOT NULL,
              state TEXT NOT NULL,
              queue_order INTEGER NOT NULL,
              PRIMARY KEY (session_id, id)
            )
          ''');
          sqlite.execute('''
            CREATE TABLE session_court_records (
              session_id INTEGER NOT NULL,
              number INTEGER NOT NULL,
              state TEXT NOT NULL,
              match_id INTEGER,
              PRIMARY KEY (session_id, number)
            )
          ''');
          sqlite.execute('''
            CREATE TABLE session_match_records (
              session_id INTEGER NOT NULL,
              id INTEGER NOT NULL,
              court_number INTEGER NOT NULL,
              team_a_first INTEGER NOT NULL,
              team_a_second INTEGER NOT NULL,
              team_b_first INTEGER NOT NULL,
              team_b_second INTEGER NOT NULL,
              state TEXT NOT NULL,
              relaxed INTEGER NOT NULL,
              result_mode TEXT,
              winner TEXT,
              completed_order INTEGER,
              PRIMARY KEY (session_id, id)
            )
          ''');
          sqlite.execute('''
            CREATE TABLE match_game_records (
              session_id INTEGER NOT NULL,
              match_id INTEGER NOT NULL,
              game_index INTEGER NOT NULL,
              side_a INTEGER NOT NULL,
              side_b INTEGER NOT NULL,
              PRIMARY KEY (session_id, match_id, game_index)
            )
          ''');
          sqlite.execute('''
            INSERT INTO play_session_records VALUES
              (21, '旧版球局', 1, 'fairRotation', 'standard21', 1, 9,
               'active', 5, 2, 4, 0, 0, 1)
          ''');
          for (var id = 1; id <= 4; id++) {
            sqlite.execute(
              'INSERT INTO session_player_records VALUES '
              "(21, $id, '旧玩家$id', 'assigned', ${id - 1})",
            );
          }
          sqlite.execute(
            "INSERT INTO session_court_records VALUES (21, 1, 'reserved', 1)",
          );
          sqlite.execute('''
            INSERT INTO session_match_records VALUES
              (21, 1, 1, 1, 2, 3, 4, 'ready', 0, NULL, NULL, NULL)
          ''');
          sqlite.execute('PRAGMA user_version = 3');
        },
      ),
    );
    store = FdPlaySessionStore(database);

    final restored = await store.load(21);

    expect(restored, isNotNull);
    expect(restored!.groups, hasLength(2));
    expect(restored.courts.single.state, CourtState.ready);
    expect(restored.matches.single.groupAId, isNotNull);
    expect(restored.matches.single.groupBId, isNotNull);
  });
}

PlaySession _session() {
  final session = PlaySession.create(
    id: 9,
    setup: const SessionSetup(
      title: '持久化测试',
      courtCount: 1,
      scorePreset: ScorePreset.standard21,
      randomSeed: 11,
    ),
  );
  for (var index = 1; index <= 6; index++) {
    session.addPlayer('玩家$index');
  }
  session.generateRandomGroups();
  session.start();
  return session;
}
