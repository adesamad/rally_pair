import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'fd_play_session_tables.dart';

part 'fd_rally_pair_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    PlaySessionRecords,
    SessionPlayerRecords,
    SessionGroupRecords,
    SessionCourtRecords,
    SessionMatchRecords,
    MatchGameRecords,
  ],
)
class FdRallyPairDatabase extends _$FdRallyPairDatabase {
  FdRallyPairDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 3) {
          await _createMissingSessionTables(migrator);
        }
        if (from >= 3 && from < 4) {
          await _upgradeSessionModel(migrator);
        }
        if (from >= 3 && from < 5) {
          await _upgradeMatchFormatModel(migrator);
        }
      },
    );
  }

  Future<void> _createMissingSessionTables(Migrator migrator) async {
    if (!await _hasTable('play_session_records')) {
      await migrator.createTable(playSessionRecords);
    }
    if (!await _hasTable('session_player_records')) {
      await migrator.createTable(sessionPlayerRecords);
    }
    if (!await _hasTable('session_court_records')) {
      await migrator.createTable(sessionCourtRecords);
    }
    if (!await _hasTable('session_group_records')) {
      await migrator.createTable(sessionGroupRecords);
    }
    if (!await _hasTable('session_match_records')) {
      await migrator.createTable(sessionMatchRecords);
    }
    if (!await _hasTable('match_game_records')) {
      await migrator.createTable(matchGameRecords);
    }
  }

  Future<void> _upgradeSessionModel(Migrator migrator) async {
    if (!await _hasTable('session_group_records')) {
      await migrator.createTable(sessionGroupRecords);
    }
    await migrator.addColumn(
      playSessionRecords,
      playSessionRecords.defaultRotationMode,
    );
    await migrator.addColumn(
      playSessionRecords,
      playSessionRecords.nextGroupId,
    );
    await migrator.addColumn(sessionCourtRecords, sessionCourtRecords.name);
    await migrator.addColumn(
      sessionCourtRecords,
      sessionCourtRecords.stayingGroupId,
    );
    await migrator.addColumn(sessionMatchRecords, sessionMatchRecords.groupAId);
    await migrator.addColumn(sessionMatchRecords, sessionMatchRecords.groupBId);
    await migrator.addColumn(
      sessionMatchRecords,
      sessionMatchRecords.rotationMode,
    );
  }

  Future<void> _upgradeMatchFormatModel(Migrator migrator) async {
    await migrator.addColumn(
      playSessionRecords,
      playSessionRecords.matchFormat,
    );
    await migrator.addColumn(playSessionRecords, playSessionRecords.singleGame);
    await migrator.addColumn(
      sessionCourtRecords,
      sessionCourtRecords.stayingPlayerId,
    );
  }

  Future<bool> _hasTable(String name) async {
    final rows = await customSelect(
      'SELECT 1 FROM sqlite_master '
      "WHERE type = 'table' AND name = ? LIMIT 1",
      variables: [Variable<String>(name)],
    ).get();
    return rows.isNotEmpty;
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'fd_rally_pair_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
