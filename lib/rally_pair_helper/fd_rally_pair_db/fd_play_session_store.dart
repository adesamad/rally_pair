import 'package:drift/drift.dart';

import '../../play_session/play_session.dart';
import 'fd_rally_pair_database.dart';

final class FdPlaySessionStore implements PlaySessionStore {
  FdPlaySessionStore(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FdRallyPairDatabase _database;
  final DateTime Function() _now;

  @override
  Future<void> save(PlaySession session) async {
    final snapshot = session.snapshot();
    await _database.transaction(() async {
      if (snapshot.status == SessionStatus.deleted) {
        await _delete(snapshot.id);
      } else {
        await _save(snapshot);
      }
    });
  }

  @override
  Future<PlaySession?> load(int id) async {
    final record = await (_database.select(
      _database.playSessionRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (record == null) return null;

    final records = await Future.wait([
      (_database.select(_database.sessionPlayerRecords)
            ..where((table) => table.sessionId.equals(id))
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get(),
      (_database.select(_database.sessionCourtRecords)
            ..where((table) => table.sessionId.equals(id))
            ..orderBy([(table) => OrderingTerm.asc(table.number)]))
          .get(),
      (_database.select(_database.sessionMatchRecords)
            ..where((table) => table.sessionId.equals(id))
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get(),
      (_database.select(_database.matchGameRecords)
            ..where((table) => table.sessionId.equals(id))
            ..orderBy([
              (table) => OrderingTerm.asc(table.matchId),
              (table) => OrderingTerm.asc(table.gameIndex),
            ]))
          .get(),
    ]);
    final players = records[0].cast<SessionPlayerRecord>();
    final courts = records[1].cast<SessionCourtRecord>();
    final matches = records[2].cast<SessionMatchRecord>();
    final games = records[3].cast<MatchGameRecord>();

    try {
      final gamesByMatch = <int, List<MatchGameRecord>>{};
      for (final game in games) {
        gamesByMatch.putIfAbsent(game.matchId, () => []).add(game);
      }
      return PlaySession.restore(
        PlaySessionSnapshot(
          id: record.id,
          setup: SessionSetup(
            title: record.title,
            courtCount: record.courtCount,
            pairingPolicy: _enum(PairingPolicy.values, record.pairingPolicy),
            scorePreset: _enum(ScorePreset.values, record.scorePreset),
            avoidRecentPartner: record.avoidRecentPartner,
            randomSeed: record.randomSeed,
          ),
          status: _enum(SessionStatus.values, record.status),
          players: [
            for (final player in players)
              SessionPlayer(
                id: player.id,
                name: player.name,
                state: _enum(PlayerState.values, player.state),
                queueOrder: player.queueOrder,
              ),
          ],
          courts: [
            for (final court in courts)
              Court(
                number: court.number,
                state: _enum(CourtState.values, court.state),
                matchId: court.matchId,
              ),
          ],
          matches: [
            for (final match in matches)
              SessionMatch(
                id: match.id,
                courtNumber: match.courtNumber,
                teamA: Team(match.teamAFirst, match.teamASecond),
                teamB: Team(match.teamBFirst, match.teamBSecond),
                state: _enum(MatchState.values, match.state),
                relaxed: match.relaxed,
                result: _result(match, gamesByMatch[match.id] ?? const []),
                completedOrder: match.completedOrder,
              ),
          ],
          nextPlayerId: record.nextPlayerId,
          nextMatchId: record.nextMatchId,
          nextQueueOrder: record.nextQueueOrder,
          pairingRound: record.pairingRound,
          completionOrder: record.completionOrder,
        ),
      );
    } on RuleViolation {
      throw const RuleViolation('invalid_persisted_session');
    } on StateError {
      throw const RuleViolation('invalid_persisted_session');
    }
  }

  @override
  Future<List<PlaySession>> loadAll() async {
    final records =
        await (_database.select(_database.playSessionRecords)..orderBy([
              (table) => OrderingTerm.desc(table.updatedAt),
              (table) => OrderingTerm.desc(table.id),
            ]))
            .get();
    final sessions = await Future.wait(
      records.map((record) async => (await load(record.id))!),
    );
    return List.unmodifiable(sessions);
  }

  @override
  Future<PlaySession?> latestActive() async {
    final record =
        await (_database.select(_database.playSessionRecords)
              ..where((table) => table.status.equals(SessionStatus.active.name))
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return record == null ? null : load(record.id);
  }

  @override
  Future<PlaySession> update(
    int id,
    void Function(PlaySession session) change,
  ) async {
    return _database.transaction(() async {
      final session = await load(id);
      if (session == null) throw const RuleViolation('session_not_found');
      change(session);
      final snapshot = session.snapshot();
      if (snapshot.status == SessionStatus.deleted) {
        await _delete(id);
      } else {
        await _save(snapshot);
      }
      return session;
    });
  }

  @override
  Future<void> delete(int id) async {
    await _database.transaction(() => _delete(id));
  }

  Future<void> _save(PlaySessionSnapshot snapshot) async {
    await _database
        .into(_database.playSessionRecords)
        .insertOnConflictUpdate(
          PlaySessionRecordsCompanion.insert(
            id: Value(snapshot.id),
            title: snapshot.setup.title,
            courtCount: snapshot.setup.courtCount,
            pairingPolicy: snapshot.setup.pairingPolicy.name,
            scorePreset: snapshot.setup.scorePreset.name,
            avoidRecentPartner: snapshot.setup.avoidRecentPartner,
            randomSeed: snapshot.setup.randomSeed,
            status: snapshot.status.name,
            nextPlayerId: snapshot.nextPlayerId,
            nextMatchId: snapshot.nextMatchId,
            nextQueueOrder: snapshot.nextQueueOrder,
            pairingRound: snapshot.pairingRound,
            completionOrder: snapshot.completionOrder,
            updatedAt: _now().microsecondsSinceEpoch,
          ),
        );
    await _deleteChildren(snapshot.id);
    await _writePlayers(snapshot);
    await _writeCourts(snapshot);
    await _writeMatches(snapshot);
  }

  Future<void> _delete(int id) async {
    await _deleteChildren(id);
    await (_database.delete(
      _database.playSessionRecords,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> _deleteChildren(int sessionId) async {
    await (_database.delete(
      _database.matchGameRecords,
    )..where((table) => table.sessionId.equals(sessionId))).go();
    await (_database.delete(
      _database.sessionMatchRecords,
    )..where((table) => table.sessionId.equals(sessionId))).go();
    await (_database.delete(
      _database.sessionCourtRecords,
    )..where((table) => table.sessionId.equals(sessionId))).go();
    await (_database.delete(
      _database.sessionPlayerRecords,
    )..where((table) => table.sessionId.equals(sessionId))).go();
  }

  Future<void> _writePlayers(PlaySessionSnapshot snapshot) async {
    if (snapshot.players.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(_database.sessionPlayerRecords, [
        for (final player in snapshot.players)
          SessionPlayerRecordsCompanion.insert(
            sessionId: snapshot.id,
            id: player.id,
            name: player.name,
            state: player.state.name,
            queueOrder: player.queueOrder,
          ),
      ]);
    });
  }

  Future<void> _writeCourts(PlaySessionSnapshot snapshot) async {
    if (snapshot.courts.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(_database.sessionCourtRecords, [
        for (final court in snapshot.courts)
          SessionCourtRecordsCompanion.insert(
            sessionId: snapshot.id,
            number: court.number,
            state: court.state.name,
            matchId: Value(court.matchId),
          ),
      ]);
    });
  }

  Future<void> _writeMatches(PlaySessionSnapshot snapshot) async {
    if (snapshot.matches.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(_database.sessionMatchRecords, [
        for (final match in snapshot.matches)
          SessionMatchRecordsCompanion.insert(
            sessionId: snapshot.id,
            id: match.id,
            courtNumber: match.courtNumber,
            teamAFirst: match.teamA.first,
            teamASecond: match.teamA.second,
            teamBFirst: match.teamB.first,
            teamBSecond: match.teamB.second,
            state: match.state.name,
            relaxed: match.relaxed,
            resultMode: Value(match.result?.mode.name),
            winner: Value(match.result?.winner.name),
            completedOrder: Value(match.completedOrder),
          ),
      ]);
      batch.insertAll(_database.matchGameRecords, [
        for (final match in snapshot.matches)
          for (
            var index = 0;
            index < (match.result?.games.length ?? 0);
            index++
          )
            MatchGameRecordsCompanion.insert(
              sessionId: snapshot.id,
              matchId: match.id,
              gameIndex: index,
              sideA: match.result!.games[index].a,
              sideB: match.result!.games[index].b,
            ),
      ]);
    });
  }

  static MatchResult? _result(
    SessionMatchRecord match,
    List<MatchGameRecord> games,
  ) {
    if (match.resultMode == null && match.winner == null && games.isEmpty) {
      return null;
    }
    if (match.resultMode == null || match.winner == null) {
      throw const RuleViolation('invalid_persisted_session');
    }
    final mode = _enum(ResultMode.values, match.resultMode!);
    final winner = _enum(Side.values, match.winner!);
    final result = switch (mode) {
      ResultMode.winnerOnly when games.isEmpty => MatchResult.winnerOnly(
        winner,
      ),
      ResultMode.gameScores when games.isNotEmpty => MatchResult.gameScores([
        for (final game in games) GameScore(game.sideA, game.sideB),
      ]),
      _ => throw const RuleViolation('invalid_persisted_session'),
    };
    if (result.winner != winner) {
      throw const RuleViolation('invalid_persisted_session');
    }
    return result;
  }

  static T _enum<T extends Enum>(List<T> values, String name) {
    return values.firstWhere(
      (value) => value.name == name,
      orElse: () => throw const RuleViolation('invalid_persisted_session'),
    );
  }
}
