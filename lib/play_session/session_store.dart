import 'package:drift/drift.dart';

import '../rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';
import 'session_models.dart';

class PlaySessionStore {
  const PlaySessionStore(this.database);

  final FdRallyPairDatabase database;

  Stream<List<PlaySession>> watchSessions() {
    final query = database.select(database.fdRallyPairSessions)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_sessionFromRow).toList(growable: false),
    );
  }

  Stream<List<SessionPlayer>> watchPlayers(int sessionId) {
    final query = database.select(database.fdRallyPairPlayers)
      ..where((row) => row.sessionId.equals(sessionId))
      ..orderBy([(row) => OrderingTerm.asc(row.queueOrder)]);
    return query.watch().map(
      (rows) => rows.map(_playerFromRow).toList(growable: false),
    );
  }

  Future<PlaySession?> findSession(int sessionId) async {
    final row = await (database.select(
      database.fdRallyPairSessions,
    )..where((row) => row.id.equals(sessionId))).getSingleOrNull();
    return row == null ? null : _sessionFromRow(row);
  }

  Future<int> createSession(SessionDraftInput input) {
    final title = input.title.trim();
    if (title.isEmpty) {
      throw const SessionRuleException('请输入球局名称');
    }
    if (input.courtCount < 1 || input.courtCount > 8) {
      throw const SessionRuleException('场地数量必须在 1 到 8 之间');
    }

    return database.transaction(() async {
      final now = DateTime.now();
      final row = await database
          .into(database.fdRallyPairSessions)
          .insertReturning(
            FdRallyPairSessionsCompanion.insert(
              title: title,
              courtCount: input.courtCount,
              pairingPolicy: input.pairingPolicy.code,
              scorePreset: input.scorePreset.code,
              avoidRecentPartner: input.avoidRecentPartner,
              status: PlaySessionStatus.draft.code,
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (var number = 1; number <= input.courtCount; number++) {
        await database
            .into(database.fdRallyPairCourts)
            .insert(
              FdRallyPairCourtsCompanion.insert(
                sessionId: row.id,
                number: number,
                state: 'available',
              ),
            );
      }
      return row.id;
    });
  }

  Future<int> addPlayer(int sessionId, String inputName) {
    final displayName = _displayName(inputName);
    if (displayName.isEmpty) {
      throw const SessionRuleException('请输入玩家名称');
    }

    return database.transaction(() async {
      final session = await findSession(sessionId);
      if (session == null) {
        throw const SessionRuleException('球局不存在，请返回后重试');
      }
      if (session.status == PlaySessionStatus.completed) {
        throw const SessionRuleException('已完成的球局不能添加玩家');
      }

      final current = await (database.select(
        database.fdRallyPairPlayers,
      )..where((row) => row.sessionId.equals(sessionId))).get();
      if (current.length >= 64) {
        throw const SessionRuleException('每场球局最多添加 64 名玩家');
      }

      final normalizedName = _normalizedName(displayName);
      final duplicate = current.any(
        (player) => player.normalizedName == normalizedName,
      );
      if (duplicate) {
        throw SessionRuleException('“$displayName”已经在本场名单中');
      }

      final queueOrder =
          current.fold<int>(
            -1,
            (maxOrder, player) =>
                player.queueOrder > maxOrder ? player.queueOrder : maxOrder,
          ) +
          1;
      final now = DateTime.now();
      final playerId = await database
          .into(database.fdRallyPairPlayers)
          .insert(
            FdRallyPairPlayersCompanion.insert(
              sessionId: sessionId,
              displayName: displayName,
              normalizedName: normalizedName,
              state: SessionPlayerState.waiting.code,
              queueOrder: queueOrder,
              createdAt: now,
            ),
          );
      await (database.update(database.fdRallyPairSessions)
            ..where((row) => row.id.equals(sessionId)))
          .write(FdRallyPairSessionsCompanion(updatedAt: Value(now)));
      return playerId;
    });
  }

  Future<void> removePlayer(int sessionId, int playerId) {
    return database.transaction(() async {
      final removed =
          await (database.delete(database.fdRallyPairPlayers)..where(
                (row) =>
                    row.id.equals(playerId) & row.sessionId.equals(sessionId),
              ))
              .go();
      if (removed == 0) {
        throw const SessionRuleException('玩家不存在，请刷新后重试');
      }
      await (database.update(
        database.fdRallyPairSessions,
      )..where((row) => row.id.equals(sessionId))).write(
        FdRallyPairSessionsCompanion(updatedAt: Value(DateTime.now())),
      );
    });
  }

  Future<int> countCourts(int sessionId) async {
    final courts = await (database.select(
      database.fdRallyPairCourts,
    )..where((row) => row.sessionId.equals(sessionId))).get();
    return courts.length;
  }

  PlaySession _sessionFromRow(FdRallyPairSession row) {
    return PlaySession(
      id: row.id,
      title: row.title,
      courtCount: row.courtCount,
      pairingPolicy: PairingPolicy.fromCode(row.pairingPolicy),
      scorePreset: ScorePreset.fromCode(row.scorePreset),
      avoidRecentPartner: row.avoidRecentPartner,
      status: PlaySessionStatus.fromCode(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SessionPlayer _playerFromRow(FdRallyPairPlayer row) {
    return SessionPlayer(
      id: row.id,
      sessionId: row.sessionId,
      displayName: row.displayName,
      state: SessionPlayerState.fromCode(row.state),
      queueOrder: row.queueOrder,
      createdAt: row.createdAt,
    );
  }

  String _displayName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizedName(String name) => _displayName(name).toLowerCase();
}
