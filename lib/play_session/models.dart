import 'dart:collection';

enum PairingPolicy { random, fairRotation }

enum ScorePreset { quick11, standard21 }

enum SessionStatus { draft, active, completed, deleted }

enum PlayerState { waiting, resting, left, assigned, playing, archived }

enum MatchState { ready, inProgress, completed, canceled }

enum CourtState { available, reserved, inPlay }

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
    required this.pairingPolicy,
    required this.scorePreset,
    required this.avoidRecentPartner,
    required this.randomSeed,
  });

  final String title;
  final int courtCount;
  final PairingPolicy pairingPolicy;
  final ScorePreset scorePreset;
  final bool avoidRecentPartner;
  final int randomSeed;

  SessionSetup copyWith({
    String? title,
    int? courtCount,
    PairingPolicy? pairingPolicy,
    ScorePreset? scorePreset,
    bool? avoidRecentPartner,
    int? randomSeed,
  }) {
    return SessionSetup(
      title: title ?? this.title,
      courtCount: courtCount ?? this.courtCount,
      pairingPolicy: pairingPolicy ?? this.pairingPolicy,
      scorePreset: scorePreset ?? this.scorePreset,
      avoidRecentPartner: avoidRecentPartner ?? this.avoidRecentPartner,
      randomSeed: randomSeed ?? this.randomSeed,
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
  const Court({required this.number, required this.state, this.matchId});

  final int number;
  final CourtState state;
  final int? matchId;

  Court copyWith({CourtState? state, int? matchId, bool clearMatch = false}) {
    return Court(
      number: number,
      state: state ?? this.state,
      matchId: clearMatch ? null : matchId ?? this.matchId,
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
    this.result,
    this.completedOrder,
  });

  final int id;
  final int courtNumber;
  final Team teamA;
  final Team teamB;
  final MatchState state;
  final bool relaxed;
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
  }) {
    return SessionMatch(
      id: id,
      courtNumber: courtNumber,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      state: state ?? this.state,
      relaxed: relaxed,
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
