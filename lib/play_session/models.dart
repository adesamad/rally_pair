import 'dart:collection';

enum PairingPolicy { random, fairRotation }

enum ScorePreset { quick11, standard21 }

enum RotationMode { winnerStays, allRotate }

enum SessionStatus { draft, active, completed, deleted }

enum PlayerState {
  ungrouped,
  grouped,
  resting,
  left,
  assigned,
  playing,
  awaitingRotation,
  staying,
  archived,
  waiting,
}

enum MatchState { ready, inProgress, resultRecorded, completed, canceled }

enum CourtState {
  available,
  ready,
  inPlay,
  awaitingRotation,
  waitingOpponent,
  reserved,
}

enum GroupState {
  waiting,
  assigned,
  playing,
  awaitingRotation,
  staying,
  dissolved,
  archived,
}

enum Side { a, b }

enum ResultMode { winnerOnly, gameScores }

final class RuleViolation implements Exception {
  const RuleViolation(this.code);

  final String code;

  @override
  String toString() => 'RuleViolation($code)';
}

final class SessionSetup {
  const SessionSetup({
    required this.title,
    required this.courtCount,
    this.pairingPolicy = PairingPolicy.fairRotation,
    required this.scorePreset,
    this.avoidRecentPartner = true,
    required this.randomSeed,
    this.defaultRotationMode = RotationMode.winnerStays,
  });

  final String title;
  final int courtCount;
  final PairingPolicy pairingPolicy;
  final ScorePreset scorePreset;
  final bool avoidRecentPartner;
  final int randomSeed;
  final RotationMode defaultRotationMode;

  SessionSetup copyWith({
    String? title,
    int? courtCount,
    PairingPolicy? pairingPolicy,
    ScorePreset? scorePreset,
    bool? avoidRecentPartner,
    int? randomSeed,
    RotationMode? defaultRotationMode,
  }) {
    return SessionSetup(
      title: title ?? this.title,
      courtCount: courtCount ?? this.courtCount,
      pairingPolicy: pairingPolicy ?? this.pairingPolicy,
      scorePreset: scorePreset ?? this.scorePreset,
      avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
      randomSeed: randomSeed ?? this.randomSeed,
      defaultRotationMode: defaultRotationMode ?? this.defaultRotationMode,
    );
  }
}

final class SessionPlayer {
  const SessionPlayer({
    required this.id,
    required this.name,
    required this.state,
    required this.queueOrder,
  });

  final int id;
  final String name;
  final PlayerState state;
  final int queueOrder;

  SessionPlayer copyWith({String? name, PlayerState? state, int? queueOrder}) {
    return SessionPlayer(
      id: id,
      name: name ?? this.name,
      state: state ?? this.state,
      queueOrder: queueOrder ?? this.queueOrder,
    );
  }
}

final class Court {
  const Court({
    required this.number,
    this.name = '',
    required this.state,
    this.matchId,
    this.stayingGroupId,
  });

  final int number;
  final String name;
  final CourtState state;
  final int? matchId;
  final int? stayingGroupId;

  Court copyWith({
    String? name,
    CourtState? state,
    int? matchId,
    int? stayingGroupId,
    bool clearMatch = false,
    bool clearStayingGroup = false,
  }) {
    return Court(
      number: number,
      name: name ?? this.name,
      state: state ?? this.state,
      matchId: clearMatch ? null : matchId ?? this.matchId,
      stayingGroupId: clearStayingGroup
          ? null
          : stayingGroupId ?? this.stayingGroupId,
    );
  }
}

final class PairingGroup {
  const PairingGroup({
    required this.id,
    required this.firstPlayerId,
    required this.secondPlayerId,
    required this.state,
    required this.queueOrder,
  });

  final int id;
  final int firstPlayerId;
  final int secondPlayerId;
  final GroupState state;
  final int queueOrder;

  List<int> get players => List.unmodifiable([firstPlayerId, secondPlayerId]);

  bool contains(int playerId) =>
      firstPlayerId == playerId || secondPlayerId == playerId;

  PairingGroup copyWith({
    int? firstPlayerId,
    int? secondPlayerId,
    GroupState? state,
    int? queueOrder,
  }) {
    return PairingGroup(
      id: id,
      firstPlayerId: firstPlayerId ?? this.firstPlayerId,
      secondPlayerId: secondPlayerId ?? this.secondPlayerId,
      state: state ?? this.state,
      queueOrder: queueOrder ?? this.queueOrder,
    );
  }
}

final class Team {
  const Team(this.first, this.second);

  final int first;
  final int second;

  List<int> get players => List.unmodifiable([first, second]);

  bool contains(int playerId) => first == playerId || second == playerId;

  Team replace(int source, int replacement) {
    if (first == source) return Team(replacement, second);
    if (second == source) return Team(first, replacement);
    throw const RuleViolation('player_not_in_match');
  }
}

final class GameScore {
  const GameScore(this.a, this.b);

  final int a;
  final int b;

  Side get winner => a > b ? Side.a : Side.b;
}

final class MatchResult {
  const MatchResult._({
    required this.mode,
    required this.winner,
    required this.games,
  });

  factory MatchResult.winnerOnly(Side winner) {
    return MatchResult._(
      mode: ResultMode.winnerOnly,
      winner: winner,
      games: const [],
    );
  }

  factory MatchResult.gameScores(List<GameScore> games) {
    if (games.isEmpty) throw const RuleViolation('games_required');
    final aWins = games.where((game) => game.winner == Side.a).length;
    final bWins = games.length - aWins;
    if (aWins == bWins) throw const RuleViolation('winner_required');
    return MatchResult._(
      mode: ResultMode.gameScores,
      winner: aWins > bWins ? Side.a : Side.b,
      games: List.unmodifiable(games),
    );
  }

  final ResultMode mode;
  final Side winner;
  final List<GameScore> games;
}

final class SessionMatch {
  const SessionMatch({
    required this.id,
    required this.courtNumber,
    required this.teamA,
    required this.teamB,
    required this.state,
    required this.relaxed,
    this.groupAId,
    this.groupBId,
    this.rotationMode,
    this.result,
    this.completedOrder,
  });

  final int id;
  final int courtNumber;
  final Team teamA;
  final Team teamB;
  final MatchState state;
  final bool relaxed;
  final int? groupAId;
  final int? groupBId;
  final RotationMode? rotationMode;
  final MatchResult? result;
  final int? completedOrder;

  List<int> get players =>
      List.unmodifiable([teamA.first, teamA.second, teamB.first, teamB.second]);

  bool contains(int playerId) =>
      teamA.contains(playerId) || teamB.contains(playerId);

  SessionMatch copyWith({
    Team? teamA,
    Team? teamB,
    MatchState? state,
    MatchResult? result,
    int? completedOrder,
    RotationMode? rotationMode,
    int? groupAId,
    int? groupBId,
  }) {
    return SessionMatch(
      id: id,
      courtNumber: courtNumber,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      state: state ?? this.state,
      relaxed: relaxed,
      groupAId: groupAId ?? this.groupAId,
      groupBId: groupBId ?? this.groupBId,
      rotationMode: rotationMode ?? this.rotationMode,
      result: result ?? this.result,
      completedOrder: completedOrder ?? this.completedOrder,
    );
  }

  SessionMatch replace(int source, int replacement) {
    if (teamA.contains(source)) {
      return copyWith(teamA: teamA.replace(source, replacement));
    }
    if (teamB.contains(source)) {
      return copyWith(teamB: teamB.replace(source, replacement));
    }
    throw const RuleViolation('player_not_in_match');
  }
}

final class PlayerStats {
  PlayerStats({
    required this.playerId,
    required this.completedMatches,
    required this.wins,
    required this.losses,
    required this.pointsFor,
    required this.pointsAgainst,
    required Map<int, int> partners,
    required Map<int, int> opponents,
  }) : partners = UnmodifiableMapView(partners),
       opponents = UnmodifiableMapView(opponents);

  final int playerId;
  final int completedMatches;
  final int wins;
  final int losses;
  final int pointsFor;
  final int pointsAgainst;
  final Map<int, int> partners;
  final Map<int, int> opponents;
}

final class BatchAddResult {
  const BatchAddResult({required this.added, required this.skipped});

  final List<SessionPlayer> added;
  final List<String> skipped;
}
