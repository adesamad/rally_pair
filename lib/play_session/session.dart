import 'dart:collection';
import 'dart:math';

import 'models.dart';
import 'pairing.dart';
import 'score_rules.dart';

final class PlaySession {
  PlaySession._({required this.id, required SessionSetup setup})
    : _setup = setup,
      _courts = {
        for (var number = 1; number <= setup.courtCount; number++)
          number: Court(number: number, state: CourtState.available),
      };

  factory PlaySession.create({required int id, required SessionSetup setup}) {
    return PlaySession._(id: id, setup: _validSetup(setup));
  }

  final int id;
  SessionSetup _setup;
  SessionStatus _status = SessionStatus.draft;
  final Map<int, SessionPlayer> _players = {};
  final Map<int, SessionMatch> _matches = {};
  Map<int, Court> _courts;
  int _nextPlayerId = 1;
  int _nextMatchId = 1;
  int _nextQueueOrder = 0;
  int _pairingRound = 0;
  int _completionOrder = 0;

  SessionSetup get setup => _setup;
  SessionStatus get status => _status;

  List<SessionPlayer> get players {
    final values = _players.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return List.unmodifiable(values);
  }

  List<SessionPlayer> get waitingPlayers {
    final values =
        _players.values
            .where((player) => player.state == PlayerState.waiting)
            .toList()
          ..sort((left, right) => left.queueOrder.compareTo(right.queueOrder));
    return List.unmodifiable(values);
  }

  List<Court> get courts {
    final values = _courts.values.toList()
      ..sort((left, right) => left.number.compareTo(right.number));
    return List.unmodifiable(values);
  }

  List<SessionMatch> get matches {
    final values = _matches.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return List.unmodifiable(values);
  }

  Map<int, PlayerStats> get stats {
    final mutable = <int, _MutableStats>{
      for (final player in _players.values) player.id: _MutableStats(player.id),
    };
    final completed =
        _matches.values
            .where((match) => match.state == MatchState.completed)
            .toList()
          ..sort(
            (left, right) =>
                left.completedOrder!.compareTo(right.completedOrder!),
          );

    for (final match in completed) {
      final result = match.result!;
      final aPoints = result.games.fold<int>(0, (sum, game) => sum + game.a);
      final bPoints = result.games.fold<int>(0, (sum, game) => sum + game.b);
      for (final playerId in match.players) {
        final value = mutable[playerId];
        if (value == null) continue;
        final onA = match.teamA.contains(playerId);
        value.completedMatches++;
        if ((onA && result.winner == Side.a) ||
            (!onA && result.winner == Side.b)) {
          value.wins++;
        } else {
          value.losses++;
        }
        if (result.mode == ResultMode.gameScores) {
          value.pointsFor += onA ? aPoints : bPoints;
          value.pointsAgainst += onA ? bPoints : aPoints;
        }
      }
      _countPartners(mutable, match.teamA);
      _countPartners(mutable, match.teamB);
      for (final aPlayer in match.teamA.players) {
        for (final bPlayer in match.teamB.players) {
          _increment(mutable[aPlayer]?.opponents, bPlayer);
          _increment(mutable[bPlayer]?.opponents, aPlayer);
        }
      }
    }

    return UnmodifiableMapView({
      for (final entry in mutable.entries) entry.key: entry.value.freeze(),
    });
  }

  PlayerStats statsFor(int playerId) {
    _player(playerId);
    return stats[playerId]!;
  }

  void updateSetup(SessionSetup setup) {
    _requireStatus(SessionStatus.draft);
    final valid = _validSetup(setup);
    _setup = valid;
    _courts = {
      for (var number = 1; number <= valid.courtCount; number++)
        number: Court(number: number, state: CourtState.available),
    };
  }

  SessionPlayer addPlayer(String name) {
    _requirePlayerEditing();
    final displayName = _displayName(name);
    _validateNewName(displayName);
    if (_players.length >= 64) {
      throw const RuleViolation('player_capacity_reached');
    }
    return _addPlayer(displayName);
  }

  BatchAddResult batchAddPlayers(String multilineNames) {
    _requirePlayerEditing();
    final known = _players.values
        .map((player) => _nameKey(player.name))
        .toSet();
    final names = <String>[];
    final skipped = <String>[];
    for (final line in multilineNames.split(RegExp(r'\r?\n'))) {
      final name = _displayName(line);
      if (name.isEmpty) continue;
      if (!known.add(_nameKey(name))) {
        skipped.add(name);
      } else {
        names.add(name);
      }
    }
    if (_players.length + names.length > 64) {
      throw const RuleViolation('player_capacity_reached');
    }
    final added = names.map(_addPlayer).toList(growable: false);
    return BatchAddResult(
      added: List.unmodifiable(added),
      skipped: List.unmodifiable(skipped),
    );
  }

  void renamePlayer(int playerId, String name) {
    _requirePlayerEditing();
    final player = _player(playerId);
    if (!_canEditPlayer(player.state)) {
      throw const RuleViolation('player_state_locked');
    }
    final displayName = _displayName(name);
    if (displayName.isEmpty) throw const RuleViolation('player_name_required');
    final key = _nameKey(displayName);
    if (_players.values.any(
      (other) => other.id != playerId && _nameKey(other.name) == key,
    )) {
      throw const RuleViolation('duplicate_player_name');
    }
    _players[playerId] = player.copyWith(name: displayName);
  }

  void setResting(int playerId) {
    _requireStatus(SessionStatus.active);
    final player = _player(playerId);
    _requirePlayerState(player, PlayerState.waiting);
    _players[playerId] = player.copyWith(state: PlayerState.resting);
  }

  void restoreWaiting(int playerId) {
    _requireStatus(SessionStatus.active);
    final player = _player(playerId);
    if (player.state != PlayerState.resting &&
        player.state != PlayerState.left) {
      throw const RuleViolation('player_state_locked');
    }
    _players[playerId] = player.copyWith(
      state: PlayerState.waiting,
      queueOrder: _takeQueueOrder(),
    );
  }

  void setLeft(int playerId) {
    _requireStatus(SessionStatus.active);
    final player = _player(playerId);
    if (player.state != PlayerState.waiting &&
        player.state != PlayerState.resting) {
      throw const RuleViolation('player_state_locked');
    }
    _players[playerId] = player.copyWith(state: PlayerState.left);
  }

  void removePlayer(int playerId) {
    _requirePlayerEditing();
    final player = _player(playerId);
    if (!_canEditPlayer(player.state)) {
      throw const RuleViolation('player_state_locked');
    }
    final hasHistory = _matches.values.any(
      (match) =>
          match.state == MatchState.completed && match.contains(playerId),
    );
    if (hasHistory) throw const RuleViolation('player_has_match_history');
    _players.remove(playerId);
  }

  void start() {
    _requireStatus(SessionStatus.draft);
    if (waitingPlayers.length < 4) {
      throw const RuleViolation('four_waiting_players_required');
    }
    _status = SessionStatus.active;
  }

  List<SessionMatch> generateAssignments() {
    _requireStatus(SessionStatus.active);
    final availableCourts = courts
        .where((court) => court.state == CourtState.available)
        .toList();
    var waiting = waitingPlayers.toList();
    final matchCount = min(availableCourts.length, waiting.length ~/ 4);
    if (matchCount == 0) return const [];

    final currentStats = stats;
    if (_setup.pairingPolicy == PairingPolicy.random) {
      final ids = Pairing.shuffle(
        waiting.map((player) => player.id).toList(),
        _seed(0),
      );
      waiting = ids.map(_player).toList();
    } else {
      waiting.sort((left, right) {
        final matches = currentStats[left.id]!.completedMatches.compareTo(
          currentStats[right.id]!.completedMatches,
        );
        return matches != 0
            ? matches
            : left.queueOrder.compareTo(right.queueOrder);
      });
    }

    final partnerHistory = _partnerHistory();
    final created = <SessionMatch>[];
    for (var index = 0; index < matchCount; index++) {
      final candidates = waiting
          .skip(index * 4)
          .take(4)
          .map((player) => player.id)
          .toList();
      final teams = Pairing.teams(
        players: candidates,
        partnerHistory: partnerHistory,
        avoidRecentPartner: _setup.avoidRecentPartner,
        seed: _seed(index + 1),
      );
      final matchId = _nextMatchId++;
      final court = availableCourts[index];
      final match = SessionMatch(
        id: matchId,
        courtNumber: court.number,
        teamA: teams.teamA,
        teamB: teams.teamB,
        state: MatchState.ready,
        relaxed: teams.relaxed,
      );
      for (final playerId in match.players) {
        final player = _player(playerId);
        _requirePlayerState(player, PlayerState.waiting);
        _players[playerId] = player.copyWith(state: PlayerState.assigned);
      }
      _courts[court.number] = court.copyWith(
        state: CourtState.reserved,
        matchId: matchId,
      );
      _matches[matchId] = match;
      created.add(match);
    }
    _pairingRound++;
    return List.unmodifiable(created);
  }

  List<SessionMatch> regenerateReadyMatches() {
    _requireStatus(SessionStatus.active);
    final ready = _matches.values
        .where((match) => match.state == MatchState.ready)
        .toList();
    if (ready.isEmpty) return const [];
    final returning = <int>[];
    for (final match in ready) {
      returning.addAll(match.players);
      _matches[match.id] = match.copyWith(state: MatchState.canceled);
      final court = _court(match.courtNumber);
      _courts[court.number] = court.copyWith(
        state: CourtState.available,
        clearMatch: true,
      );
    }
    _returnToFront(returning);
    return generateAssignments();
  }

  void swapReadyPlayer({
    required int matchId,
    required int sourcePlayerId,
    required int replacementPlayerId,
  }) {
    _requireStatus(SessionStatus.active);
    final match = _match(matchId);
    if (match.state != MatchState.ready) {
      throw const RuleViolation('match_not_ready');
    }
    if (!match.contains(sourcePlayerId)) {
      throw const RuleViolation('player_not_in_match');
    }
    final source = _player(sourcePlayerId);
    final replacement = _player(replacementPlayerId);
    _requirePlayerState(source, PlayerState.assigned);
    _requirePlayerState(replacement, PlayerState.waiting);
    _matches[matchId] = match.replace(sourcePlayerId, replacementPlayerId);
    _players[sourcePlayerId] = source.copyWith(state: PlayerState.waiting);
    _players[replacementPlayerId] = replacement.copyWith(
      state: PlayerState.assigned,
    );
  }

  void startMatch(int matchId) {
    _requireStatus(SessionStatus.active);
    final match = _match(matchId);
    if (match.state != MatchState.ready) {
      throw const RuleViolation('match_not_ready');
    }
    final court = _court(match.courtNumber);
    if (court.state != CourtState.reserved || court.matchId != matchId) {
      throw const RuleViolation('court_match_mismatch');
    }
    for (final playerId in match.players) {
      _requirePlayerState(_player(playerId), PlayerState.assigned);
    }

    _matches[matchId] = match.copyWith(state: MatchState.inProgress);
    _courts[court.number] = court.copyWith(state: CourtState.inPlay);
    for (final playerId in match.players) {
      _players[playerId] = _player(
        playerId,
      ).copyWith(state: PlayerState.playing);
    }
  }

  void finishMatch(int matchId, MatchResult result) {
    _requireStatus(SessionStatus.active);
    final match = _match(matchId);
    if (match.state != MatchState.inProgress) {
      throw const RuleViolation('match_not_in_progress');
    }
    final court = _court(match.courtNumber);
    if (court.state != CourtState.inPlay || court.matchId != matchId) {
      throw const RuleViolation('court_match_mismatch');
    }
    for (final playerId in match.players) {
      _requirePlayerState(_player(playerId), PlayerState.playing);
    }
    ScoreRules.validate(_setup.scorePreset, result);

    _completionOrder++;
    _matches[matchId] = match.copyWith(
      state: MatchState.completed,
      result: result,
      completedOrder: _completionOrder,
    );
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearMatch: true,
    );
    for (final playerId in match.players) {
      _players[playerId] = _player(
        playerId,
      ).copyWith(state: PlayerState.waiting, queueOrder: _takeQueueOrder());
    }
  }

  void cancelMatch(int matchId) {
    _requireStatus(SessionStatus.active);
    final match = _match(matchId);
    if (match.state != MatchState.ready &&
        match.state != MatchState.inProgress) {
      throw const RuleViolation('match_cannot_be_canceled');
    }
    final expectedPlayerState = match.state == MatchState.ready
        ? PlayerState.assigned
        : PlayerState.playing;
    final expectedCourtState = match.state == MatchState.ready
        ? CourtState.reserved
        : CourtState.inPlay;
    final court = _court(match.courtNumber);
    if (court.state != expectedCourtState || court.matchId != matchId) {
      throw const RuleViolation('court_match_mismatch');
    }
    for (final playerId in match.players) {
      _requirePlayerState(_player(playerId), expectedPlayerState);
    }

    _matches[matchId] = match.copyWith(state: MatchState.canceled);
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearMatch: true,
    );
    _returnToFront(match.players);
  }

  void correctMatch(int matchId, MatchResult result) {
    _requireNotDeleted();
    final match = _match(matchId);
    if (match.state != MatchState.completed) {
      throw const RuleViolation('match_not_completed');
    }
    ScoreRules.validate(_setup.scorePreset, result);
    _matches[matchId] = match.copyWith(result: result);
  }

  void complete() {
    _requireStatus(SessionStatus.active);
    if (_matches.values.any(
      (match) =>
          match.state == MatchState.ready ||
          match.state == MatchState.inProgress,
    )) {
      throw const RuleViolation('unfinished_matches_exist');
    }
    if (_courts.values.any((court) => court.state != CourtState.available)) {
      throw const RuleViolation('occupied_courts_exist');
    }
    _status = SessionStatus.completed;
    for (final player in _players.values.toList()) {
      _players[player.id] = player.copyWith(state: PlayerState.archived);
    }
  }

  PlaySession duplicate({
    required int id,
    required String title,
    int? randomSeed,
  }) {
    if (_status != SessionStatus.active && _status != SessionStatus.completed) {
      throw const RuleViolation('session_cannot_be_duplicated');
    }
    final duplicate = PlaySession.create(
      id: id,
      setup: _setup.copyWith(title: title, randomSeed: randomSeed),
    );
    for (final player in players) {
      duplicate.addPlayer(player.name);
    }
    return duplicate;
  }

  void delete() {
    _requireNotDeleted();
    _status = SessionStatus.deleted;
    _players.clear();
    _matches.clear();
    _courts.clear();
  }

  static SessionSetup _validSetup(SessionSetup setup) {
    final title = _displayName(setup.title);
    if (title.isEmpty) throw const RuleViolation('session_title_required');
    if (setup.courtCount < 1 || setup.courtCount > 8) {
      throw const RuleViolation('court_count_out_of_range');
    }
    return setup.copyWith(title: title);
  }

  static String _displayName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _nameKey(String value) => _displayName(value).toLowerCase();

  void _requirePlayerEditing() {
    if (_status != SessionStatus.draft && _status != SessionStatus.active) {
      throw const RuleViolation('session_players_locked');
    }
  }

  static bool _canEditPlayer(PlayerState state) {
    return state == PlayerState.waiting ||
        state == PlayerState.resting ||
        state == PlayerState.left;
  }

  void _validateNewName(String name) {
    if (name.isEmpty) throw const RuleViolation('player_name_required');
    final key = _nameKey(name);
    if (_players.values.any((player) => _nameKey(player.name) == key)) {
      throw const RuleViolation('duplicate_player_name');
    }
  }

  SessionPlayer _addPlayer(String name) {
    final player = SessionPlayer(
      id: _nextPlayerId++,
      name: name,
      state: PlayerState.waiting,
      queueOrder: _takeQueueOrder(),
    );
    _players[player.id] = player;
    return player;
  }

  int _takeQueueOrder() => _nextQueueOrder++;

  int _seed(int offset) => _setup.randomSeed + (_pairingRound * 1009) + offset;

  Map<int, Set<int>> _partnerHistory() {
    final history = <int, Set<int>>{
      for (final player in _players.values) player.id: <int>{},
    };
    final completed = _matches.values
        .where((match) => match.state == MatchState.completed)
        .toList();
    for (final match in completed) {
      _rememberPartners(history, match.teamA);
      _rememberPartners(history, match.teamB);
    }
    return history;
  }

  static void _rememberPartners(Map<int, Set<int>> history, Team team) {
    history[team.first]?.add(team.second);
    history[team.second]?.add(team.first);
  }

  void _returnToFront(Iterable<int> playerIds) {
    final returning = playerIds.map(_player).toList()
      ..sort((left, right) => left.queueOrder.compareTo(right.queueOrder));
    final returningIds = returning.map((player) => player.id).toSet();
    final waiting = waitingPlayers
        .where((player) => !returningIds.contains(player.id))
        .toList();
    var order = 0;
    for (final player in [...returning, ...waiting]) {
      _players[player.id] = player.copyWith(
        state: PlayerState.waiting,
        queueOrder: order++,
      );
    }
    final maxOrder = _players.values.fold<int>(-1, (current, player) {
      return max(current, player.queueOrder);
    });
    _nextQueueOrder = maxOrder + 1;
  }

  SessionPlayer _player(int playerId) {
    final player = _players[playerId];
    if (player == null) throw const RuleViolation('player_not_found');
    return player;
  }

  SessionMatch _match(int matchId) {
    final match = _matches[matchId];
    if (match == null) throw const RuleViolation('match_not_found');
    return match;
  }

  Court _court(int courtNumber) {
    final court = _courts[courtNumber];
    if (court == null) throw const RuleViolation('court_not_found');
    return court;
  }

  void _requireStatus(SessionStatus status) {
    if (_status != status) throw const RuleViolation('session_state_locked');
  }

  void _requireNotDeleted() {
    if (_status == SessionStatus.deleted) {
      throw const RuleViolation('session_deleted');
    }
  }

  static void _requirePlayerState(SessionPlayer player, PlayerState state) {
    if (player.state != state) {
      throw const RuleViolation('player_state_locked');
    }
  }

  static void _countPartners(Map<int, _MutableStats> stats, Team team) {
    _increment(stats[team.first]?.partners, team.second);
    _increment(stats[team.second]?.partners, team.first);
  }

  static void _increment(Map<int, int>? values, int key) {
    if (values == null) return;
    values[key] = (values[key] ?? 0) + 1;
  }
}

final class _MutableStats {
  _MutableStats(this.playerId);

  final int playerId;
  int completedMatches = 0;
  int wins = 0;
  int losses = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;
  final Map<int, int> partners = {};
  final Map<int, int> opponents = {};

  PlayerStats freeze() {
    return PlayerStats(
      playerId: playerId,
      completedMatches: completedMatches,
      wins: wins,
      losses: losses,
      pointsFor: pointsFor,
      pointsAgainst: pointsAgainst,
      partners: partners,
      opponents: opponents,
    );
  }
}
