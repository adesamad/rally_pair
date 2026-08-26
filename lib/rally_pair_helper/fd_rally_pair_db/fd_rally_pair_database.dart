import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'fd_rally_pair_session_tables.dart';

part 'fd_rally_pair_database.g.dart';

@DriftDatabase(
  tables: <Type>[FdRallyPairSessions, FdRallyPairPlayers, FdRallyPairCourts],
)
class FdRallyPairDatabase extends _$FdRallyPairDatabase {
  FdRallyPairDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(fdRallyPairSessions);
        await migrator.createTable(fdRallyPairPlayers);
        await migrator.createTable(fdRallyPairCourts);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'fd_rally_pair_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
