import 'dart:collection';

import 'models.dart';

final class PlaySessionSnapshot {
  PlaySessionSnapshot({
    required this.id,
    required this.setup,
    required this.status,
    required List<SessionPlayer> players,
    required List<Court> courts,
    required List<SessionMatch> matches,
    required this.nextPlayerId,
    required this.nextMatchId,
    required this.nextQueueOrder,
    required this.pairingRound,
    required this.completionOrder,
  }) : players = UnmodifiableListView(List.of(players)),
       courts = UnmodifiableListView(List.of(courts)),
       matches = UnmodifiableListView(List.of(matches));

  final int id;
  final SessionSetup setup;
  final SessionStatus status;
  final List<SessionPlayer> players;
  final List<Court> courts;
  final List<SessionMatch> matches;
  final int nextPlayerId;
  final int nextMatchId;
  final int nextQueueOrder;
  final int pairingRound;
  final int completionOrder;
}
