import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'fd_play_session_tables.dart';

part 'fd_rally_pair_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    PlaySessionRecords,
    SessionPlayerRecords,
    SessionCourtRecords,
    SessionMatchRecords,
    MatchGameRecords,
  ],
)
class FdRallyPairDatabase extends _$FdRallyPairDatabase {
  FdRallyPairDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 3) {
          await _createMissingSessionTables(migrator);
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
    if (!await _hasTable('session_match_records')) {
      await migrator.createTable(sessionMatchRecords);
    }
    if (!await _hasTable('match_game_records')) {
      await migrator.createTable(matchGameRecords);
    }
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
