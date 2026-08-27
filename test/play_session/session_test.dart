import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  group('PlaySession setup and roster', () {
    test('normalizes setup and enforces court bounds', () {
      final session = PlaySession.create(
        id: 1,
        setup: _setup(title: '  周六   晚场  '),
      );

      expect(session.setup.title, '周六 晚场');
      expect(session.courts.length, 2);
      expect(
        () => PlaySession.create(id: 2, setup: _setup(courtCount: 9)),
        _throwsViolation('court_count_out_of_range'),
      );
    });

    test('batch add normalizes names and skips duplicates', () {
      final session = _session();
      session.addPlayer('Alice');

      final result = session.batchAddPlayers(
        ' alice \nBob\n  Mary   Jane  \nBob\n\n',
      );

      expect(result.added.map((player) => player.name), ['Bob', 'Mary Jane']);
      expect(result.skipped, ['alice', 'Bob']);
      expect(session.players.map((player) => player.name), [
        'Alice',
        'Bob',
        'Mary Jane',
      ]);
    });

    test('capacity failure does not partially add a batch', () {
      final session = _session();
      for (var index = 1; index <= 63; index++) {
        session.addPlayer('P$index');
      }

      expect(
        () => session.batchAddPlayers('P64\nP65'),
        _throwsViolation('player_capacity_reached'),
      );
      expect(session.players.length, 63);
    });

    test('requires four waiting players before starting', () {
      final session = _session(playerCount: 3);

      expect(session.start, _throwsViolation('four_waiting_players_required'));
      expect(session.status, SessionStatus.draft);
    });

    test('setup can change only while the session is a draft', () {
      final session = _session(playerCount: 4);
      session.updateSetup(
        _setup(
          title: '周日晚场',
          courtCount: 3,
          pairingPolicy: PairingPolicy.random,
          scorePreset: ScorePreset.quick11,
        ),
      );

      expect(session.setup.title, '周日晚场');
      expect(session.courts.length, 3);
      session.start();
      expect(
        () => session.updateSetup(_setup(title: '不应生效')),
        _throwsViolation('session_state_locked'),
      );
      expect(session.setup.title, '周日晚场');
    });

    test('supports waiting, resting, and left roster transitions', () {
      final session = _session(playerCount: 4)..start();

      session.setResting(1);
      session.setLeft(2);
      expect(session.players[0].state, PlayerState.resting);
      expect(session.players[1].state, PlayerState.left);

      session.restoreWaiting(1);
      session.restoreWaiting(2);
      expect(session.waitingPlayers.map((player) => player.id), [3, 4, 1, 2]);
    });
  });

  group('PlaySession assignment and match lifecycle', () {
    test('assigns only available courts with no repeated players', () {
      final session = _session(playerCount: 10, courtCount: 3)..start();

      final matches = session.generateAssignments();
      final assigned = matches.expand((match) => match.players).toList();

      expect(matches.length, 2);
      expect(assigned.toSet().length, 8);
      expect(session.courts.map((court) => court.state), [
        CourtState.reserved,
        CourtState.reserved,
        CourtState.available,
      ]);
    });

    test('completed players return behind existing waiting players', () {
      final session = _session(playerCount: 12, courtCount: 2)..start();
      final matches = session.generateAssignments();
      final completedPlayers = matches.first.players;

      session.startMatch(matches.first.id);
      session.finishMatch(matches.first.id, MatchResult.winnerOnly(Side.a));

      expect(session.waitingPlayers.take(4).map((player) => player.id), [
        9,
        10,
        11,
        12,
      ]);
      expect(
        session.waitingPlayers.skip(4).map((player) => player.id),
        completedPlayers,
      );
      for (final playerId in completedPlayers) {
        expect(session.statsFor(playerId).completedMatches, 1);
      }
    });

    test('invalid finish is atomic', () {
      final session = _session(
        playerCount: 4,
        courtCount: 1,
        scorePreset: ScorePreset.quick11,
      )..start();
      final match = session.generateAssignments().single;
      session.startMatch(match.id);

      expect(
        () => session.finishMatch(
          match.id,
          MatchResult.gameScores(const [GameScore(12, 10)]),
        ),
        _throwsViolation('invalid_quick_11_score'),
      );
      expect(session.matches.single.state, MatchState.inProgress);
      expect(session.courts.single.state, CourtState.inPlay);
      expect(
        match.players.map((id) => session.players[id - 1].state),
        everyElement(PlayerState.playing),
      );
      expect(session.stats.values, everyElement(_hasNoCompletedMatches));
    });

    test('cancel returns players to the front and does not affect stats', () {
      final session = _session(playerCount: 8, courtCount: 1)..start();
      final match = session.generateAssignments().single;

      session.cancelMatch(match.id);

      expect(session.waitingPlayers.map((player) => player.id), [
        ...match.players,
        5,
        6,
        7,
        8,
      ]);
      expect(session.matches.single.state, MatchState.canceled);
      expect(session.courts.single.state, CourtState.available);
      expect(session.stats.values, everyElement(_hasNoCompletedMatches));
    });

    test('swaps a ready player with a waiting player', () {
      final session = _session(playerCount: 8, courtCount: 1)..start();
      final match = session.generateAssignments().single;
      final source = match.players.first;

      session.swapReadyPlayer(
        matchId: match.id,
        sourcePlayerId: source,
        replacementPlayerId: 5,
      );

      expect(session.matches.single.contains(source), isFalse);
      expect(session.matches.single.contains(5), isTrue);
      expect(_player(session, source).state, PlayerState.waiting);
      expect(_player(session, 5).state, PlayerState.assigned);
    });

    test('regenerates ready matches without touching an in-progress match', () {
      final session = _session(playerCount: 8, courtCount: 2)..start();
      final initial = session.generateAssignments();
      session.startMatch(initial.first.id);

      final regenerated = session.regenerateReadyMatches();

      expect(session.matches.first.state, MatchState.inProgress);
      expect(session.matches[1].state, MatchState.canceled);
      expect(regenerated.single.courtNumber, initial[1].courtNumber);
      expect(regenerated.single.id, isNot(initial[1].id));
    });
  });

  group('PlaySession policy, stats, and closure', () {
    test(
      'fair rotation gives the next court to players with fewer matches',
      () {
        final session = _session(playerCount: 8, courtCount: 1)..start();
        final first = session.generateAssignments().single;
        session.startMatch(first.id);
        session.finishMatch(first.id, MatchResult.winnerOnly(Side.a));

        final second = session.generateAssignments().single;

        expect(second.players.toSet(), {5, 6, 7, 8});
      },
    );

    test('the same random seed produces the same assignments', () {
      final first = _session(
        id: 1,
        playerCount: 8,
        courtCount: 2,
        pairingPolicy: PairingPolicy.random,
      )..start();
      final second = _session(
        id: 2,
        playerCount: 8,
        courtCount: 2,
        pairingPolicy: PairingPolicy.random,
      )..start();

      expect(
        first.generateAssignments().map(_matchSignature),
        second.generateAssignments().map(_matchSignature),
      );
    });

    test('score correction fully recomputes winner and points stats', () {
      final session = _session(playerCount: 4, scorePreset: ScorePreset.quick11)
        ..start();
      final match = session.generateAssignments().single;
      session.startMatch(match.id);
      session.finishMatch(
        match.id,
        MatchResult.gameScores(const [GameScore(11, 7)]),
      );

      expect(session.statsFor(match.teamA.first).wins, 1);
      expect(session.statsFor(match.teamA.first).pointsFor, 11);
      session.correctMatch(
        match.id,
        MatchResult.gameScores(const [GameScore(5, 11)]),
      );

      expect(session.statsFor(match.teamA.first).wins, 0);
      expect(session.statsFor(match.teamA.first).losses, 1);
      expect(session.statsFor(match.teamA.first).pointsFor, 5);
      expect(session.statsFor(match.teamA.first).pointsAgainst, 11);
      expect(session.statsFor(match.teamB.first).wins, 1);
    });

    test('completed history blocks player removal', () {
      final session = _session(playerCount: 4)..start();
      final match = session.generateAssignments().single;
      session.startMatch(match.id);
      session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));

      expect(
        () => session.removePlayer(match.players.first),
        _throwsViolation('player_has_match_history'),
      );
    });

    test('completion requires no unfinished match and archives the roster', () {
      final session = _session(playerCount: 4)..start();
      final match = session.generateAssignments().single;

      expect(session.complete, _throwsViolation('unfinished_matches_exist'));
      session.cancelMatch(match.id);
      session.complete();

      expect(session.status, SessionStatus.completed);
      expect(
        session.players.map((player) => player.state),
        everyElement(PlayerState.archived),
      );
      expect(
        () => session.addPlayer('Late player'),
        _throwsViolation('session_players_locked'),
      );
    });

    test('duplicate keeps setup and names but resets runtime history', () {
      final session = _session(playerCount: 4)..start();
      final match = session.generateAssignments().single;
      session.startMatch(match.id);
      session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));
      session.complete();

      final duplicate = session.duplicate(id: 2, title: '下周复用', randomSeed: 99);

      expect(duplicate.status, SessionStatus.draft);
      expect(duplicate.setup.title, '下周复用');
      expect(duplicate.setup.courtCount, session.setup.courtCount);
      expect(duplicate.setup.randomSeed, 99);
      expect(
        duplicate.players.map((player) => player.name),
        session.players.map((player) => player.name),
      );
      expect(duplicate.matches, isEmpty);
      expect(duplicate.stats.values, everyElement(_hasNoCompletedMatches));
      expect(
        duplicate.players.map((player) => player.state),
        everyElement(PlayerState.waiting),
      );
    });

    test('delete moves the aggregate to its terminal state atomically', () {
      final session = _session(playerCount: 4)..start();
      session.generateAssignments();

      session.delete();

      expect(session.status, SessionStatus.deleted);
      expect(session.players, isEmpty);
      expect(session.matches, isEmpty);
      expect(session.courts, isEmpty);
      expect(session.stats, isEmpty);
      expect(
        session.generateAssignments,
        _throwsViolation('session_state_locked'),
      );
      expect(session.delete, _throwsViolation('session_deleted'));
    });
  });
}

final _hasNoCompletedMatches = isA<PlayerStats>().having(
  (stats) => stats.completedMatches,
  'completedMatches',
  0,
);

SessionSetup _setup({
  String title = '周六晚场',
  int courtCount = 2,
  PairingPolicy pairingPolicy = PairingPolicy.fairRotation,
  ScorePreset scorePreset = ScorePreset.standard21,
}) {
  return SessionSetup(
    title: title,
    courtCount: courtCount,
    pairingPolicy: pairingPolicy,
    scorePreset: scorePreset,
    avoidRecentPartner: true,
    randomSeed: 20260722,
  );
}

PlaySession _session({
  int id = 1,
  int playerCount = 0,
  int courtCount = 2,
  PairingPolicy pairingPolicy = PairingPolicy.fairRotation,
  ScorePreset scorePreset = ScorePreset.standard21,
}) {
  final session = PlaySession.create(
    id: id,
    setup: _setup(
      courtCount: courtCount,
      pairingPolicy: pairingPolicy,
      scorePreset: scorePreset,
    ),
  );
  for (var index = 1; index <= playerCount; index++) {
    session.addPlayer('P$index');
  }
  return session;
}

SessionPlayer _player(PlaySession session, int playerId) {
  return session.players.singleWhere((player) => player.id == playerId);
}

String _matchSignature(SessionMatch match) {
  return '${match.courtNumber}:${match.teamA.first}-${match.teamA.second}:'
      '${match.teamB.first}-${match.teamB.second}';
}

Matcher _throwsViolation(String code) {
  return throwsA(
    isA<RuleViolation>().having((error) => error.code, 'code', code),
  );
}
