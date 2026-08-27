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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(playSessionRecords);
          await migrator.createTable(sessionPlayerRecords);
          await migrator.createTable(sessionCourtRecords);
          await migrator.createTable(sessionMatchRecords);
          await migrator.createTable(matchGameRecords);
        }
      },
    );
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
