import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_db.dart';

void main() {
  group('FdPlaySessionStore', () {
    late FdRallyPairDatabase database;
    late FdPlaySessionStore store;
    var clock = 0;

    setUp(() {
      database = FdRallyPairDatabase(NativeDatabase.memory());
      store = FdPlaySessionStore(
        database,
        now: () => DateTime.fromMicrosecondsSinceEpoch(++clock),
      );
    });

    tearDown(() => database.close());

    test(
      'round-trips a mixed active session without losing behavior',
      () async {
        final original = _mixedSession();

        await store.save(original);
        final restored = await store.load(original.id);

        expect(restored, isNotNull);
        expect(_sessionData(restored!), _sessionData(original));
        expect(_statsData(restored), _statsData(original));
        expect(restored.players.map((player) => player.state).toSet(), {
          PlayerState.waiting,
          PlayerState.resting,
          PlayerState.left,
          PlayerState.assigned,
          PlayerState.playing,
        });

        _cancelOpenMatches(original);
        _cancelOpenMatches(restored);
        expect(
          original.generateAssignments().map(_matchData),
          restored.generateAssignments().map(_matchData),
        );
      },
    );

    test(
      'loads all sessions and returns the most recently saved active one',
      () async {
        final draft = _draftSession(id: 1, playerCount: 4);
        final olderActive = _draftSession(id: 2, playerCount: 4)..start();
        final newerActive = _draftSession(id: 3, playerCount: 4)..start();
        await store.save(draft);
        await store.save(olderActive);
        await store.save(newerActive);

        expect((await store.latestActive())?.id, 3);
        await store.update(2, (session) => session.renamePlayer(1, '新名字'));

        expect((await store.latestActive())?.id, 2);
        expect((await store.loadAll()).map((session) => session.id), [2, 3, 1]);
      },
    );

    test('preserves winner-only results without inventing points', () async {
      final session = _draftSession(id: 4, playerCount: 4)..start();
      final match = session.generateAssignments().single;
      session.startMatch(match.id);
      session.finishMatch(match.id, MatchResult.winnerOnly(Side.b));

      await store.save(session);
      final restored = (await store.load(4))!;

      expect(restored.matches.single.result?.mode, ResultMode.winnerOnly);
      expect(restored.matches.single.result?.winner, Side.b);
      expect(restored.statsFor(match.teamB.first).wins, 1);
      expect(restored.statsFor(match.teamB.first).pointsFor, 0);
      expect(restored.statsFor(match.teamB.first).pointsAgainst, 0);
    });

    test('restores an active session after reopening the database', () async {
      final directory = await Directory.systemTemp.createTemp(
        'rally_pair_store_test_',
      );
      final file = File('${directory.path}/restart.sqlite');
      await database.close();
      database = FdRallyPairDatabase(NativeDatabase(file));
      store = FdPlaySessionStore(database);
      final original = _mixedSession();
      await store.save(original);
      await database.close();

      database = FdRallyPairDatabase(NativeDatabase(file));
      store = FdPlaySessionStore(database);
      final restored = await store.latestActive();

      expect(restored, isNotNull);
      expect(_sessionData(restored!), _sessionData(original));
      await database.close();
      database = FdRallyPairDatabase(NativeDatabase.memory());
      store = FdPlaySessionStore(database);
      await directory.delete(recursive: true);
    });

    test('rolls back every table when a match insert fails', () async {
      final session = _draftSession(id: 1, playerCount: 4)..start();
      await store.save(session);
      final before = _sessionData((await store.load(1))!);
      await database.customStatement('''
        CREATE TRIGGER fail_session_match_insert
        BEFORE INSERT ON session_match_records
        BEGIN
          SELECT RAISE(FAIL, 'forced failure');
        END
      ''');

      await expectLater(
        store.update(1, (current) => current.generateAssignments()),
        throwsA(anything),
      );
      await database.customStatement('DROP TRIGGER fail_session_match_insert');

      expect(_sessionData((await store.load(1))!), before);
      expect(
        await database.select(database.sessionMatchRecords).get(),
        isEmpty,
      );
      expect(await database.select(database.matchGameRecords).get(), isEmpty);
    });

    test('physically deletes the aggregate and all owned rows', () async {
      final session = _mixedSession();
      await store.save(session);

      await store.delete(session.id);

      expect(await store.load(session.id), isNull);
      expect(await database.select(database.playSessionRecords).get(), isEmpty);
      expect(
        await database.select(database.sessionPlayerRecords).get(),
        isEmpty,
      );
      expect(
        await database.select(database.sessionCourtRecords).get(),
        isEmpty,
      );
      expect(
        await database.select(database.sessionMatchRecords).get(),
        isEmpty,
      );
      expect(await database.select(database.matchGameRecords).get(), isEmpty);
    });

    test('saving a deleted aggregate removes its stored history', () async {
      final session = _mixedSession();
      await store.save(session);

      session.delete();
      await store.save(session);

      expect(await store.load(session.id), isNull);
      expect(await store.loadAll(), isEmpty);
    });

    test('rejects corrupted persisted enum values', () async {
      final session = _draftSession(id: 1, playerCount: 4);
      await store.save(session);
      await database.customStatement(
        "UPDATE play_session_records SET status = 'unknown' WHERE id = 1",
      );

      expect(
        () => store.load(1),
        _throwsViolation('invalid_persisted_session'),
      );
    });

    test('upgrades the existing empty v1 database shell', () async {
      await database.close();
      database = FdRallyPairDatabase(
        NativeDatabase.memory(
          setup: (rawDatabase) {
            rawDatabase.execute('PRAGMA user_version = 1');
          },
        ),
      );
      store = FdPlaySessionStore(database);
      final session = _draftSession(id: 9, playerCount: 4);

      await store.save(session);

      expect((await store.load(9))?.players.length, 4);
      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 2);
    });
  });
}

PlaySession _draftSession({required int id, required int playerCount}) {
  final session = PlaySession.create(
    id: id,
    setup: const SessionSetup(
      title: '周六晚场',
      courtCount: 2,
      pairingPolicy: PairingPolicy.fairRotation,
      scorePreset: ScorePreset.quick11,
      avoidRecentPartner: true,
      randomSeed: 20260722,
    ),
  );
  for (var index = 1; index <= playerCount; index++) {
    session.addPlayer('P$index');
  }
  return session;
}

PlaySession _mixedSession() {
  final session = _draftSession(id: 7, playerCount: 12)..start();
  session.setResting(11);
  session.setLeft(12);
  final initial = session.generateAssignments();
  session.startMatch(initial.first.id);
  session.finishMatch(
    initial.first.id,
    MatchResult.gameScores(const [GameScore(11, 7)]),
  );
  session.startMatch(initial[1].id);
  session.generateAssignments();
  return session;
}

void _cancelOpenMatches(PlaySession session) {
  final open = session.matches
      .where(
        (match) =>
            match.state == MatchState.ready ||
            match.state == MatchState.inProgress,
      )
      .toList();
  for (final match in open) {
    session.cancelMatch(match.id);
  }
}

Map<String, Object?> _sessionData(PlaySession session) {
  final snapshot = session.snapshot();
  return {
    'id': snapshot.id,
    'setup': [
      snapshot.setup.title,
      snapshot.setup.courtCount,
      snapshot.setup.pairingPolicy.name,
      snapshot.setup.scorePreset.name,
      snapshot.setup.avoidRecentPartner,
      snapshot.setup.randomSeed,
    ],
    'status': snapshot.status.name,
    'counters': [
      snapshot.nextPlayerId,
      snapshot.nextMatchId,
      snapshot.nextQueueOrder,
      snapshot.pairingRound,
      snapshot.completionOrder,
    ],
    'players': [
      for (final player in snapshot.players)
        [player.id, player.name, player.state.name, player.queueOrder],
    ],
    'courts': [
      for (final court in snapshot.courts)
        [court.number, court.state.name, court.matchId],
    ],
    'matches': [for (final match in snapshot.matches) _matchData(match)],
  };
}

Map<String, Object?> _matchData(SessionMatch match) {
  return {
    'id': match.id,
    'court': match.courtNumber,
    'teams': [match.teamA.players, match.teamB.players],
    'state': match.state.name,
    'relaxed': match.relaxed,
    'result': match.result == null
        ? null
        : [
            match.result!.mode.name,
            match.result!.winner.name,
            for (final game in match.result!.games) [game.a, game.b],
          ],
    'completedOrder': match.completedOrder,
  };
}

Map<int, Object?> _statsData(PlaySession session) {
  return {
    for (final entry in session.stats.entries)
      entry.key: [
        entry.value.completedMatches,
        entry.value.wins,
        entry.value.losses,
        entry.value.pointsFor,
        entry.value.pointsAgainst,
        entry.value.partners,
        entry.value.opponents,
      ],
  };
}

Matcher _throwsViolation(String code) {
  return throwsA(
    isA<RuleViolation>().having((error) => error.code, 'code', code),
  );
}
