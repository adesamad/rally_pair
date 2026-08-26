import 'package:drift/drift.dart';

class FdRallyPairSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  IntColumn get courtCount => integer()();

  TextColumn get pairingPolicy => text()();

  TextColumn get scorePreset => text()();

  BoolColumn get avoidRecentPartner => boolean()();

  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

class FdRallyPairPlayers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId => integer().references(
    FdRallyPairSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get displayName => text()();

  TextColumn get normalizedName => text()();

  TextColumn get state => text()();

  IntColumn get queueOrder => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, normalizedName},
  ];
}

class FdRallyPairCourts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId => integer().references(
    FdRallyPairSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get number => integer()();

  TextColumn get state => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, number},
  ];
}
