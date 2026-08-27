import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  group('PlaySession snapshot', () {
    test('restores counters and deterministic behavior', () {
      final original = _activeSession();
      final first = original.generateAssignments().single;
      original.startMatch(first.id);
      original.finishMatch(first.id, MatchResult.winnerOnly(Side.a));

      final restored = PlaySession.restore(original.snapshot());

      expect(_sessionData(restored), _sessionData(original));
      final originalNext = original.generateAssignments().single;
      final restoredNext = restored.generateAssignments().single;
      expect(_matchData(restoredNext), _matchData(originalNext));
    });

    test('snapshot owns immutable collection copies', () {
      final session = _activeSession();
      final snapshot = session.snapshot();

      expect(
        () => snapshot.players.add(snapshot.players.first),
        throwsUnsupportedError,
      );
      expect(() => snapshot.courts.clear(), throwsUnsupportedError);
      expect(() => snapshot.matches.clear(), throwsUnsupportedError);
    });

    test('rejects duplicated identities in restored data', () {
      final session = _activeSession();
      final snapshot = session.snapshot();

      expect(
        () => PlaySession.restore(
          PlaySessionSnapshot(
            id: snapshot.id,
            setup: snapshot.setup,
            status: snapshot.status,
            players: [snapshot.players.first, snapshot.players.first],
            courts: snapshot.courts,
            matches: snapshot.matches,
            nextPlayerId: snapshot.nextPlayerId,
            nextMatchId: snapshot.nextMatchId,
            nextQueueOrder: snapshot.nextQueueOrder,
            pairingRound: snapshot.pairingRound,
            completionOrder: snapshot.completionOrder,
          ),
        ),
        _throwsViolation('invalid_session_snapshot'),
      );
    });

    test('rejects a court and match state mismatch', () {
      final session = _activeSession();
      final match = session.generateAssignments().single;
      final snapshot = session.snapshot();

      expect(
        () => PlaySession.restore(
          PlaySessionSnapshot(
            id: snapshot.id,
            setup: snapshot.setup,
            status: snapshot.status,
            players: snapshot.players,
            courts: [Court(number: 1, state: CourtState.available)],
            matches: snapshot.matches,
            nextPlayerId: snapshot.nextPlayerId,
            nextMatchId: snapshot.nextMatchId,
            nextQueueOrder: snapshot.nextQueueOrder,
            pairingRound: snapshot.pairingRound,
            completionOrder: snapshot.completionOrder,
          ),
        ),
        _throwsViolation('invalid_session_snapshot'),
      );
      expect(match.state, MatchState.ready);
    });
  });
}

PlaySession _activeSession() {
  final session = PlaySession.create(
    id: 1,
    setup: const SessionSetup(
      title: '周六晚场',
      courtCount: 1,
      pairingPolicy: PairingPolicy.fairRotation,
      scorePreset: ScorePreset.standard21,
      avoidRecentPartner: true,
      randomSeed: 20260722,
    ),
  );
  for (var index = 1; index <= 8; index++) {
    session.addPlayer('P$index');
  }
  session.start();
  return session;
}

Map<String, Object?> _sessionData(PlaySession session) {
  final snapshot = session.snapshot();
  return {
    'id': snapshot.id,
    'status': snapshot.status.name,
    'nextPlayerId': snapshot.nextPlayerId,
    'nextMatchId': snapshot.nextMatchId,
    'nextQueueOrder': snapshot.nextQueueOrder,
    'pairingRound': snapshot.pairingRound,
    'completionOrder': snapshot.completionOrder,
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
    'teamA': match.teamA.players,
    'teamB': match.teamB.players,
    'state': match.state.name,
    'relaxed': match.relaxed,
    'resultMode': match.result?.mode.name,
    'winner': match.result?.winner.name,
    'games': [
      for (final game in match.result?.games ?? const <GameScore>[])
        [game.a, game.b],
    ],
    'completedOrder': match.completedOrder,
  };
}

Matcher _throwsViolation(String code) {
  return throwsA(
    isA<RuleViolation>().having((error) => error.code, 'code', code),
  );
}
