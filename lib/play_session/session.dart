import 'dart:collection';
import 'dart:math';

import 'models.dart';
import 'pairing.dart';
import 'score_rules.dart';
import 'snapshot.dart';

final class PlaySession {
  PlaySession._({required this.id, required SessionSetup setup})
    : _setup = setup,
      _courts = {
        for (var number = 1; number <= setup.courtCount; number++)
          number: Court(
            number: number,
            name: '$number 号场',
            state: CourtState.available,
          ),
      };

  factory PlaySession.create({required int id, required SessionSetup setup}) {
    return PlaySession._(id: id, setup: _validSetup(setup));
  }

  factory PlaySession.restore(PlaySessionSnapshot snapshot) {
    final session = PlaySession._(
      id: snapshot.id,
      setup: _validSetup(snapshot.setup),
    );
    if (snapshot.players.map((player) => player.id).toSet().length !=
            snapshot.players.length ||
        snapshot.groups.map((group) => group.id).toSet().length !=
            snapshot.groups.length ||
        snapshot.courts.map((court) => court.number).toSet().length !=
            snapshot.courts.length ||
        snapshot.matches.map((match) => match.id).toSet().length !=
            snapshot.matches.length) {
      throw const RuleViolation('invalid_session_snapshot');
    }
    session
      .._status = snapshot.status
      .._players.addEntries(
        snapshot.players.map((player) => MapEntry(player.id, player)),
      )
      .._groups.addEntries(
        snapshot.groups.map((group) => MapEntry(group.id, group)),
      )
      .._courts = {for (final court in snapshot.courts) court.number: court}
      .._matches.addEntries(
        snapshot.matches.map((match) => MapEntry(match.id, match)),
      )
      .._nextPlayerId = snapshot.nextPlayerId
      .._nextGroupId = snapshot.nextGroupId
      .._nextMatchId = snapshot.nextMatchId
      .._nextQueueOrder = snapshot.nextQueueOrder
      .._pairingRound = snapshot.pairingRound
      .._completionOrder = snapshot.completionOrder;
    session._upgradeLegacyState();
    session._validateRestoredState();
    return session;
  }

  final int id;
  SessionSetup _setup;
  SessionStatus _status = SessionStatus.draft;
  final Map<int, SessionPlayer> _players = {};
  final Map<int, PairingGroup> _groups = {};
  final Map<int, SessionMatch> _matches = {};
  Map<int, Court> _courts;
  int _nextPlayerId = 1;
  int _nextGroupId = 1;
  int _nextMatchId = 1;
  int _nextQueueOrder = 0;
  int _pairingRound = 0;
  int _completionOrder = 0;

  SessionSetup get setup => _setup;
  SessionStatus get status => _status;

  PlaySessionSnapshot snapshot() {
    return PlaySessionSnapshot(
      id: id,
      setup: _setup,
      status: _status,
      players: players,
      groups: groups,
      courts: courts,
      matches: matches,
      nextPlayerId: _nextPlayerId,
      nextGroupId: _nextGroupId,
      nextMatchId: _nextMatchId,
      nextQueueOrder: _nextQueueOrder,
      pairingRound: _pairingRound,
      completionOrder: _completionOrder,
    );
  }

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

  List<PairingGroup> get groups {
    final values = _groups.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return List.unmodifiable(values);
  }

  List<PairingGroup> get waitingGroups {
    final values =
        _groups.values
            .where((group) => group.state == GroupState.waiting)
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
    final existing = courts.take(valid.courtCount).toList(growable: false);
    final updated = <int, Court>{
      for (final court in existing) court.number: court,
    };
    var nextNumber = updated.keys.isEmpty ? 1 : updated.keys.reduce(max) + 1;
    while (updated.length < valid.courtCount) {
      updated[nextNumber] = Court(
        number: nextNumber,
        name: '$nextNumber 号场',
        state: CourtState.available,
      );
      nextNumber++;
    }
    _courts = updated;
  }

  Court addCourt(String name) {
    _requirePlayerEditing();
    if (_courts.length >= 8) {
      throw const RuleViolation('court_capacity_reached');
    }
    final displayName = _displayName(name);
    if (displayName.isEmpty) throw const RuleViolation('court_name_required');
    final key = _nameKey(displayName);
    if (_courts.values.any((court) => _nameKey(court.name) == key)) {
      throw const RuleViolation('duplicate_court_name');
    }
    final number = _courts.keys.isEmpty ? 1 : _courts.keys.reduce(max) + 1;
    final court = Court(
      number: number,
      name: displayName,
      state: CourtState.available,
    );
    _courts[number] = court;
    _setup = _setup.copyWith(courtCount: _courts.length);
    return court;
  }

  void removeCourt(int courtNumber) {
    _requirePlayerEditing();
    final court = _court(courtNumber);
    if (court.state != CourtState.available ||
        court.matchId != null ||
        court.stayingGroupId != null) {
      throw const RuleViolation('court_state_locked');
    }
    _courts.remove(courtNumber);
    _setup = _setup.copyWith(courtCount: _courts.length);
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
    _requirePlayerState(player, PlayerState.ungrouped);
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
      state: PlayerState.ungrouped,
      queueOrder: _takeQueueOrder(),
    );
  }

  void setLeft(int playerId) {
    _requireStatus(SessionStatus.active);
    final player = _player(playerId);
    if (player.state != PlayerState.ungrouped &&
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
    if (waitingGroups.length < 2 || _courts.isEmpty) {
      throw const RuleViolation('two_waiting_groups_required');
    }
    _status = SessionStatus.active;
  }

  List<PairingGroup> generateRandomGroups([Iterable<int>? selectedPlayerIds]) {
    _requirePlayerEditing();
    final selected = selectedPlayerIds?.toSet();
    final eligible = _players.values
        .where(
          (player) =>
              player.state == PlayerState.ungrouped &&
              (selected == null || selected.contains(player.id)),
        )
        .map((player) => player.id)
        .toList();
    final shuffled = Pairing.shuffle(eligible, _seed(0));
    final created = <PairingGroup>[];
    for (var index = 0; index + 1 < shuffled.length; index += 2) {
      created.add(createManualGroup(shuffled[index], shuffled[index + 1]));
    }
    _pairingRound++;
    return List.unmodifiable(created);
  }

  PairingGroup createManualGroup(int firstPlayerId, int secondPlayerId) {
    _requirePlayerEditing();
    if (firstPlayerId == secondPlayerId) {
      throw const RuleViolation('group_players_must_differ');
    }
    final first = _player(firstPlayerId);
    final second = _player(secondPlayerId);
    _requirePlayerState(first, PlayerState.ungrouped);
    _requirePlayerState(second, PlayerState.ungrouped);
    final group = PairingGroup(
      id: _nextGroupId++,
      firstPlayerId: firstPlayerId,
      secondPlayerId: secondPlayerId,
      state: GroupState.waiting,
      queueOrder: _takeQueueOrder(),
    );
    _groups[group.id] = group;
    _players[firstPlayerId] = first.copyWith(state: PlayerState.grouped);
    _players[secondPlayerId] = second.copyWith(state: PlayerState.grouped);
    return group;
  }

  void dissolveGroup(int groupId) {
    final group = _group(groupId);
    _requireGroupState(group, GroupState.waiting);
    _groups[groupId] = group.copyWith(state: GroupState.dissolved);
    for (final playerId in group.players) {
      _players[playerId] = _player(
        playerId,
      ).copyWith(state: PlayerState.ungrouped);
    }
  }

  void updateGroup({
    required int groupId,
    required int sourcePlayerId,
    required int replacementPlayerId,
  }) {
    final group = _group(groupId);
    _requireGroupState(group, GroupState.waiting);
    if (!group.contains(sourcePlayerId)) {
      throw const RuleViolation('player_not_in_group');
    }
    final replacement = _player(replacementPlayerId);
    _requirePlayerState(replacement, PlayerState.ungrouped);
    final source = _player(sourcePlayerId);
    final updated = group.firstPlayerId == sourcePlayerId
        ? group.copyWith(firstPlayerId: replacementPlayerId)
        : group.copyWith(secondPlayerId: replacementPlayerId);
    _groups[groupId] = updated;
    _players[source.id] = source.copyWith(state: PlayerState.ungrouped);
    _players[replacement.id] = replacement.copyWith(state: PlayerState.grouped);
  }

  void randomizeGroupQueue() {
    final shuffled = Pairing.shuffle(
      waitingGroups.map((group) => group.id).toList(),
      _seed(1),
    );
    for (var index = 0; index < shuffled.length; index++) {
      final group = _group(shuffled[index]);
      _groups[group.id] = group.copyWith(queueOrder: index);
    }
    _nextQueueOrder = max(_nextQueueOrder, shuffled.length);
    _pairingRound++;
  }

  void reorderGroup(int groupId, int targetIndex) {
    final ordered = waitingGroups.toList();
    final sourceIndex = ordered.indexWhere((group) => group.id == groupId);
    if (sourceIndex < 0 || targetIndex < 0 || targetIndex >= ordered.length) {
      throw const RuleViolation('group_order_out_of_range');
    }
    final group = ordered.removeAt(sourceIndex);
    ordered.insert(targetIndex, group);
    for (var index = 0; index < ordered.length; index++) {
      _groups[ordered[index].id] = ordered[index].copyWith(queueOrder: index);
    }
  }

  List<SessionMatch> generateAssignments() {
    _requireStatus(SessionStatus.active);
    final created = <SessionMatch>[];
    for (final court in courts.where(
      (court) => court.state == CourtState.available,
    )) {
      if (waitingGroups.length < 2) break;
      created.add(assignNextGroups(court.number));
    }
    return List.unmodifiable(created);
  }

  SessionMatch assignNextGroups(int courtNumber) {
    if (waitingGroups.length < 2) {
      throw const RuleViolation('two_waiting_groups_required');
    }
    return assignGroups(
      courtNumber: courtNumber,
      firstGroupId: waitingGroups[0].id,
      secondGroupId: waitingGroups[1].id,
    );
  }

  SessionMatch assignGroups({
    required int courtNumber,
    required int firstGroupId,
    required int secondGroupId,
  }) {
    _requireStatus(SessionStatus.active);
    if (firstGroupId == secondGroupId) {
      throw const RuleViolation('groups_must_differ');
    }
    final court = _court(courtNumber);
    if (court.state != CourtState.available) {
      throw const RuleViolation('court_not_available');
    }
    final first = _group(firstGroupId);
    final second = _group(secondGroupId);
    _requireGroupState(first, GroupState.waiting);
    _requireGroupState(second, GroupState.waiting);
    final match = _createMatch(court, first, second);
    return match;
  }

  List<SessionMatch> regenerateReadyMatches() {
    _requireStatus(SessionStatus.active);
    final ready = _matches.values
        .where((match) => match.state == MatchState.ready)
        .toList();
    if (ready.isEmpty) return const [];
    final returning = <int>[];
    for (final match in ready) {
      if (match.groupAId != null) returning.add(match.groupAId!);
      if (match.groupBId != null) returning.add(match.groupBId!);
      _matches[match.id] = match.copyWith(state: MatchState.canceled);
      final court = _court(match.courtNumber);
      _courts[court.number] = court.copyWith(
        state: CourtState.available,
        clearMatch: true,
      );
    }
    _returnGroupsToFront(returning);
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
    if ((court.state != CourtState.ready &&
            court.state != CourtState.reserved) ||
        court.matchId != matchId) {
      throw const RuleViolation('court_match_mismatch');
    }
    final groups = _matchGroups(match);
    for (final group in groups) {
      _requireGroupState(group, GroupState.assigned);
    }

    _matches[matchId] = match.copyWith(state: MatchState.inProgress);
    _courts[court.number] = court.copyWith(state: CourtState.inPlay);
    for (final group in groups) {
      _groups[group.id] = group.copyWith(state: GroupState.playing);
      for (final playerId in group.players) {
        _players[playerId] = _player(
          playerId,
        ).copyWith(state: PlayerState.playing);
      }
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
    final groups = _matchGroups(match);
    for (final group in groups) {
      _requireGroupState(group, GroupState.playing);
    }
    ScoreRules.validate(_setup.scorePreset, result);

    _matches[matchId] = match.copyWith(
      state: MatchState.resultRecorded,
      result: result,
    );
    _courts[court.number] = court.copyWith(state: CourtState.awaitingRotation);
    for (final group in groups) {
      _groups[group.id] = group.copyWith(state: GroupState.awaitingRotation);
      for (final playerId in group.players) {
        _players[playerId] = _player(
          playerId,
        ).copyWith(state: PlayerState.awaitingRotation);
      }
    }
  }

  void cancelMatch(int matchId) {
    _requireStatus(SessionStatus.active);
    final match = _match(matchId);
    if (match.state != MatchState.ready &&
        match.state != MatchState.inProgress) {
      throw const RuleViolation('match_cannot_be_canceled');
    }
    final expectedCourtState = match.state == MatchState.ready
        ? CourtState.ready
        : CourtState.inPlay;
    final court = _court(match.courtNumber);
    if (court.state != expectedCourtState || court.matchId != matchId) {
      throw const RuleViolation('court_match_mismatch');
    }
    final groups = _matchGroups(match);

    _matches[matchId] = match.copyWith(state: MatchState.canceled);
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearMatch: true,
    );
    _returnGroupsToFront(groups.map((group) => group.id));
  }

  void resolveWinnerStays(int matchId) {
    final match = _match(matchId);
    _requireResultRecorded(match);
    final court = _court(match.courtNumber);
    final matchGroups = _matchGroups(match);
    final winner = match.result!.winner == Side.a
        ? matchGroups[0]
        : matchGroups[1];
    final loser = match.result!.winner == Side.a
        ? matchGroups[1]
        : matchGroups[0];
    final next = waitingGroups.isEmpty ? null : waitingGroups.first;
    _completeRecordedMatch(match, RotationMode.winnerStays);
    _enqueueGroup(loser);
    if (next == null) {
      _setGroupState(winner, GroupState.staying, PlayerState.staying);
      _courts[court.number] = court.copyWith(
        state: CourtState.waitingOpponent,
        clearMatch: true,
        stayingGroupId: winner.id,
      );
    } else {
      _setGroupState(winner, GroupState.waiting, PlayerState.grouped);
      _courts[court.number] = court.copyWith(
        state: CourtState.available,
        clearMatch: true,
      );
      _createMatch(_court(court.number), _group(winner.id), next);
    }
  }

  void resolveAllRotate(int matchId) {
    final match = _match(matchId);
    _requireResultRecorded(match);
    final court = _court(match.courtNumber);
    final next = waitingGroups.take(2).toList();
    final current = _matchGroups(match);
    _completeRecordedMatch(match, RotationMode.allRotate);
    for (final group in current) {
      _enqueueGroup(group);
    }
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearMatch: true,
    );
    if (next.length == 2) {
      _createMatch(_court(court.number), next[0], next[1]);
    }
  }

  void fillStayingCourt(int courtNumber, [int? selectedGroupId]) {
    final court = _court(courtNumber);
    if (court.state != CourtState.waitingOpponent ||
        court.stayingGroupId == null) {
      throw const RuleViolation('court_not_waiting_opponent');
    }
    final next = selectedGroupId == null
        ? (waitingGroups.isEmpty ? null : waitingGroups.first)
        : _group(selectedGroupId);
    if (next == null) throw const RuleViolation('waiting_group_required');
    _requireGroupState(next, GroupState.waiting);
    final staying = _group(court.stayingGroupId!);
    _setGroupState(staying, GroupState.waiting, PlayerState.grouped);
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearStayingGroup: true,
    );
    _createMatch(_court(court.number), _group(staying.id), next);
  }

  void releaseStayingCourt(int courtNumber) {
    final court = _court(courtNumber);
    if (court.state != CourtState.waitingOpponent ||
        court.stayingGroupId == null) {
      throw const RuleViolation('court_not_waiting_opponent');
    }
    _enqueueGroup(_group(court.stayingGroupId!));
    _courts[court.number] = court.copyWith(
      state: CourtState.available,
      clearMatch: true,
      clearStayingGroup: true,
    );
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
          match.state == MatchState.inProgress ||
          match.state == MatchState.resultRecorded,
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
    for (final group in _groups.values.toList()) {
      if (group.state != GroupState.dissolved) {
        _groups[group.id] = group.copyWith(state: GroupState.archived);
      }
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
    duplicate._courts = {
      for (final court in courts)
        court.number: Court(
          number: court.number,
          name: court.name,
          state: CourtState.available,
        ),
    };
    for (final player in players) {
      duplicate.addPlayer(player.name);
    }
    return duplicate;
  }

  void delete() {
    _requireNotDeleted();
    _status = SessionStatus.deleted;
    _players.clear();
    _groups.clear();
    _matches.clear();
    _courts.clear();
  }

  void _validateRestoredState() {
    if (_nextPlayerId <= _maxOrZero(_players.keys) ||
        _nextGroupId <= _maxOrZero(_groups.keys) ||
        _nextMatchId <= _maxOrZero(_matches.keys) ||
        _nextQueueOrder <=
            _maxOrNegativeOne(
              _players.values.map((player) => player.queueOrder),
            ) ||
        _pairingRound < 0 ||
        _completionOrder < 0) {
      throw const RuleViolation('invalid_session_snapshot');
    }

    if (_status == SessionStatus.deleted) {
      if (_players.isNotEmpty ||
          _groups.isNotEmpty ||
          _courts.isNotEmpty ||
          _matches.isNotEmpty) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      return;
    }

    final activeGroupPlayers = <int>{};
    for (final group in _groups.values) {
      if (group.id <= 0 ||
          group.firstPlayerId == group.secondPlayerId ||
          !group.players.every(_players.containsKey) ||
          group.queueOrder < 0) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (group.state != GroupState.dissolved &&
          group.state != GroupState.archived) {
        for (final playerId in group.players) {
          if (!activeGroupPlayers.add(playerId)) {
            throw const RuleViolation('invalid_session_snapshot');
          }
        }
      }
    }

    if (_courts.length != _setup.courtCount) {
      throw const RuleViolation('invalid_session_snapshot');
    }

    final expectedPlayerStates = <int, PlayerState>{};
    var maxCompletionOrder = 0;
    for (final match in _matches.values) {
      if (match.id <= 0 ||
          match.players.any((playerId) => playerId <= 0) ||
          match.players.toSet().length != 4 ||
          !match.players.every(_players.containsKey) ||
          !_courts.containsKey(match.courtNumber)) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (match.state == MatchState.completed) {
        if (match.result == null ||
            match.completedOrder == null ||
            match.completedOrder! <= 0) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        ScoreRules.validate(_setup.scorePreset, match.result!);
        maxCompletionOrder = max(maxCompletionOrder, match.completedOrder!);
      } else if (match.state == MatchState.resultRecorded) {
        if (match.result == null || match.completedOrder != null) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        ScoreRules.validate(_setup.scorePreset, match.result!);
      } else if (match.result != null || match.completedOrder != null) {
        throw const RuleViolation('invalid_session_snapshot');
      }

      final expectedState = switch (match.state) {
        MatchState.ready => PlayerState.assigned,
        MatchState.inProgress => PlayerState.playing,
        MatchState.resultRecorded => PlayerState.awaitingRotation,
        MatchState.completed || MatchState.canceled => null,
      };
      if (expectedState != null) {
        if (_status != SessionStatus.active) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        final court = _courts[match.courtNumber]!;
        final expectedCourtState = switch (match.state) {
          MatchState.ready => CourtState.ready,
          MatchState.inProgress => CourtState.inPlay,
          MatchState.resultRecorded => CourtState.awaitingRotation,
          _ => throw const RuleViolation('invalid_session_snapshot'),
        };
        final legacyReady =
            match.state == MatchState.ready &&
            court.state == CourtState.reserved;
        if ((!legacyReady && court.state != expectedCourtState) ||
            court.matchId != match.id) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        for (final playerId in match.players) {
          if (expectedPlayerStates.containsKey(playerId)) {
            throw const RuleViolation('invalid_session_snapshot');
          }
          expectedPlayerStates[playerId] = expectedState;
        }
      }
    }
    if (_completionOrder < maxCompletionOrder) {
      throw const RuleViolation('invalid_session_snapshot');
    }

    for (final player in _players.values) {
      if (player.id <= 0 || player.queueOrder < 0) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      final expected = expectedPlayerStates[player.id];
      if (expected != null && player.state != expected) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (expected == null &&
          (player.state == PlayerState.assigned ||
              player.state == PlayerState.playing)) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (_status == SessionStatus.draft &&
          player.state != PlayerState.ungrouped &&
          player.state != PlayerState.grouped &&
          player.state != PlayerState.waiting) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (_status == SessionStatus.completed &&
          player.state != PlayerState.archived) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (_status == SessionStatus.active &&
          player.state == PlayerState.archived) {
        throw const RuleViolation('invalid_session_snapshot');
      }
    }

    for (final court in _courts.values) {
      if (court.number <= 0) {
        throw const RuleViolation('invalid_session_snapshot');
      }
      if (court.state == CourtState.available) {
        if (court.matchId != null) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        continue;
      }
      if (court.state == CourtState.waitingOpponent) {
        if (court.matchId != null || court.stayingGroupId == null) {
          throw const RuleViolation('invalid_session_snapshot');
        }
        continue;
      }
      final match = _matches[court.matchId];
      final expectedMatchState = switch (court.state) {
        CourtState.ready || CourtState.reserved => MatchState.ready,
        CourtState.inPlay => MatchState.inProgress,
        CourtState.awaitingRotation => MatchState.resultRecorded,
        _ => throw const RuleViolation('invalid_session_snapshot'),
      };
      if (match == null ||
          match.courtNumber != court.number ||
          match.state != expectedMatchState) {
        throw const RuleViolation('invalid_session_snapshot');
      }
    }

    if (_status == SessionStatus.draft && _matches.isNotEmpty) {
      throw const RuleViolation('invalid_session_snapshot');
    }
    if (_status == SessionStatus.completed &&
        _courts.values.any((court) => court.state != CourtState.available)) {
      throw const RuleViolation('invalid_session_snapshot');
    }
  }

  void _upgradeLegacyState() {
    for (final player in _players.values.toList()) {
      if (player.state == PlayerState.waiting) {
        _players[player.id] = player.copyWith(state: PlayerState.ungrouped);
      }
    }
    if (_groups.isNotEmpty) return;
    for (final match in _matches.values.toList()) {
      if (match.state != MatchState.ready &&
          match.state != MatchState.inProgress) {
        continue;
      }
      final groupState = match.state == MatchState.ready
          ? GroupState.assigned
          : GroupState.playing;
      final first = PairingGroup(
        id: _nextGroupId++,
        firstPlayerId: match.teamA.first,
        secondPlayerId: match.teamA.second,
        state: groupState,
        queueOrder: _takeQueueOrder(),
      );
      final second = PairingGroup(
        id: _nextGroupId++,
        firstPlayerId: match.teamB.first,
        secondPlayerId: match.teamB.second,
        state: groupState,
        queueOrder: _takeQueueOrder(),
      );
      _groups[first.id] = first;
      _groups[second.id] = second;
      _matches[match.id] = match.copyWith(
        groupAId: first.id,
        groupBId: second.id,
      );
      final court = _court(match.courtNumber);
      if (court.state == CourtState.reserved) {
        _courts[court.number] = court.copyWith(state: CourtState.ready);
      }
    }
  }

  static int _maxOrZero(Iterable<int> values) {
    return values.isEmpty ? 0 : values.reduce(max);
  }

  static int _maxOrNegativeOne(Iterable<int> values) {
    return values.isEmpty ? -1 : values.reduce(max);
  }

  static SessionSetup _validSetup(SessionSetup setup) {
    final title = _displayName(setup.title);
    if (title.isEmpty) throw const RuleViolation('session_title_required');
    if (setup.courtCount < 0 || setup.courtCount > 8) {
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
        state == PlayerState.ungrouped ||
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
      state: PlayerState.ungrouped,
      queueOrder: _takeQueueOrder(),
    );
    _players[player.id] = player;
    return player;
  }

  int _takeQueueOrder() => _nextQueueOrder++;

  int _seed(int offset) => _setup.randomSeed + (_pairingRound * 1009) + offset;

  SessionMatch _createMatch(
    Court court,
    PairingGroup first,
    PairingGroup second,
  ) {
    _requireGroupState(first, GroupState.waiting);
    _requireGroupState(second, GroupState.waiting);
    final match = SessionMatch(
      id: _nextMatchId++,
      courtNumber: court.number,
      teamA: Team(first.firstPlayerId, first.secondPlayerId),
      teamB: Team(second.firstPlayerId, second.secondPlayerId),
      groupAId: first.id,
      groupBId: second.id,
      state: MatchState.ready,
      relaxed: false,
    );
    _matches[match.id] = match;
    _courts[court.number] = court.copyWith(
      state: CourtState.ready,
      matchId: match.id,
      clearStayingGroup: true,
    );
    _setGroupState(first, GroupState.assigned, PlayerState.assigned);
    _setGroupState(second, GroupState.assigned, PlayerState.assigned);
    return match;
  }

  void _requireResultRecorded(SessionMatch match) {
    if (match.state != MatchState.resultRecorded || match.result == null) {
      throw const RuleViolation('match_result_not_recorded');
    }
    final court = _court(match.courtNumber);
    if (court.state != CourtState.awaitingRotation ||
        court.matchId != match.id) {
      throw const RuleViolation('court_match_mismatch');
    }
  }

  void _completeRecordedMatch(SessionMatch match, RotationMode mode) {
    _completionOrder++;
    _matches[match.id] = match.copyWith(
      state: MatchState.completed,
      rotationMode: mode,
      completedOrder: _completionOrder,
    );
  }

  void _setGroupState(
    PairingGroup group,
    GroupState state,
    PlayerState playerState,
  ) {
    _groups[group.id] = group.copyWith(state: state);
    for (final playerId in group.players) {
      _players[playerId] = _player(playerId).copyWith(state: playerState);
    }
  }

  void _enqueueGroup(PairingGroup group) {
    _groups[group.id] = group.copyWith(
      state: GroupState.waiting,
      queueOrder: _takeQueueOrder(),
    );
    for (final playerId in group.players) {
      _players[playerId] = _player(
        playerId,
      ).copyWith(state: PlayerState.grouped);
    }
  }

  List<PairingGroup> _matchGroups(SessionMatch match) {
    if (match.groupAId == null || match.groupBId == null) {
      throw const RuleViolation('match_group_mismatch');
    }
    return [_group(match.groupAId!), _group(match.groupBId!)];
  }

  void _returnGroupsToFront(Iterable<int> groupIds) {
    final returning = groupIds.map(_group).toList();
    final returningIds = returning.map((group) => group.id).toSet();
    final waiting = waitingGroups
        .where((group) => !returningIds.contains(group.id))
        .toList();
    var order = 0;
    for (final group in [...returning, ...waiting]) {
      _groups[group.id] = group.copyWith(
        state: GroupState.waiting,
        queueOrder: order++,
      );
      for (final playerId in group.players) {
        _players[playerId] = _player(
          playerId,
        ).copyWith(state: PlayerState.grouped);
      }
    }
    _nextQueueOrder = max(_nextQueueOrder, order);
  }

  SessionPlayer _player(int playerId) {
    final player = _players[playerId];
    if (player == null) throw const RuleViolation('player_not_found');
    return player;
  }

  PairingGroup _group(int groupId) {
    final group = _groups[groupId];
    if (group == null) throw const RuleViolation('group_not_found');
    return group;
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

  static void _requireGroupState(PairingGroup group, GroupState state) {
    if (group.state != state) {
      throw const RuleViolation('group_state_locked');
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
