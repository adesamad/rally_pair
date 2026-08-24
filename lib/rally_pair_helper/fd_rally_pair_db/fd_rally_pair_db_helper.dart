import 'fd_rally_pair_database.dart';

class FdRallyPairDb {
  factory FdRallyPairDb() => _instance;

  FdRallyPairDb._();

  static final _instance = FdRallyPairDb._();

  FdRallyPairDatabase? _database;

  FdRallyPairDatabase get database => _database ??= FdRallyPairDatabase();

  Future<T> transaction<T>(Future<T> Function(FdRallyPairDatabase db) action) {
    return database.transaction(() => action(database));
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }
}
