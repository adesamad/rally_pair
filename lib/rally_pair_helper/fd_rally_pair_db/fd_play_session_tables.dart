import 'package:drift/drift.dart';

class PlaySessionRecords extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  IntColumn get courtCount => integer()();
  TextColumn get pairingPolicy => text()();
  TextColumn get scorePreset => text()();
  BoolColumn get avoidRecentPartner => boolean()();
  IntColumn get randomSeed => integer()();
  TextColumn get status => text()();
  IntColumn get nextPlayerId => integer()();
  IntColumn get nextMatchId => integer()();
  IntColumn get nextQueueOrder => integer()();
  IntColumn get pairingRound => integer()();
  IntColumn get completionOrder => integer()();
  TextColumn get defaultRotationMode =>
      text().withDefault(const Constant('winnerStays'))();
  IntColumn get nextGroupId => integer().withDefault(const Constant(1))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SessionPlayerRecords extends Table {
  IntColumn get sessionId => integer()();
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get state => text()();
  IntColumn get queueOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, id};
}

class SessionCourtRecords extends Table {
  IntColumn get sessionId => integer()();
  IntColumn get number => integer()();
  TextColumn get state => text()();
  IntColumn get matchId => integer().nullable()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get stayingGroupId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, number};
}

class SessionGroupRecords extends Table {
  IntColumn get sessionId => integer()();
  IntColumn get id => integer()();
  IntColumn get firstPlayerId => integer()();
  IntColumn get secondPlayerId => integer()();
  TextColumn get state => text()();
  IntColumn get queueOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, id};
}

class SessionMatchRecords extends Table {
  IntColumn get sessionId => integer()();
  IntColumn get id => integer()();
  IntColumn get courtNumber => integer()();
  IntColumn get teamAFirst => integer()();
  IntColumn get teamASecond => integer()();
  IntColumn get teamBFirst => integer()();
  IntColumn get teamBSecond => integer()();
  TextColumn get state => text()();
  BoolColumn get relaxed => boolean()();
  TextColumn get resultMode => text().nullable()();
  TextColumn get winner => text().nullable()();
  IntColumn get completedOrder => integer().nullable()();
  IntColumn get groupAId => integer().nullable()();
  IntColumn get groupBId => integer().nullable()();
  TextColumn get rotationMode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, id};
}

class MatchGameRecords extends Table {
  IntColumn get sessionId => integer()();
  IntColumn get matchId => integer()();
  IntColumn get gameIndex => integer()();
  IntColumn get sideA => integer()();
  IntColumn get sideB => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, matchId, gameIndex};
}
