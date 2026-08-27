import 'dart:math';

import 'models.dart';

final class PairingPlan {
  const PairingPlan({
    required this.teamA,
    required this.teamB,
    required this.relaxed,
  });

  final Team teamA;
  final Team teamB;
  final bool relaxed;
}

final class Pairing {
  const Pairing._();

  static List<int> shuffle(List<int> players, int seed) {
    final shuffled = List<int>.of(players);
    shuffled.shuffle(Random(seed));
    return shuffled;
  }

  static PairingPlan teams({
    required List<int> players,
    required Map<int, Set<int>> partnerHistory,
    required bool avoidRecentPartner,
    required int seed,
  }) {
    if (players.length != 4 || players.toSet().length != 4) {
      throw const RuleViolation('four_unique_players_required');
    }

    final options = [
      PairingPlan(
        teamA: Team(players[0], players[1]),
        teamB: Team(players[2], players[3]),
        relaxed: false,
      ),
      PairingPlan(
        teamA: Team(players[0], players[2]),
        teamB: Team(players[1], players[3]),
        relaxed: false,
      ),
      PairingPlan(
        teamA: Team(players[0], players[3]),
        teamB: Team(players[1], players[2]),
        relaxed: false,
      ),
    ];
    if (!avoidRecentPartner) return options.first;

    final penalties = options.map((option) {
      return _penalty(option.teamA, partnerHistory) +
          _penalty(option.teamB, partnerHistory);
    }).toList();
    final minimum = penalties.reduce(min);
    final best = <PairingPlan>[
      for (var index = 0; index < options.length; index++)
        if (penalties[index] == minimum) options[index],
    ];
    final selected = best[Random(seed).nextInt(best.length)];
    return PairingPlan(
      teamA: selected.teamA,
      teamB: selected.teamB,
      relaxed: minimum > 0,
    );
  }

  static int _penalty(Team team, Map<int, Set<int>> partnerHistory) {
    return (partnerHistory[team.first]?.contains(team.second) ?? false) ||
            (partnerHistory[team.second]?.contains(team.first) ?? false)
        ? 1
        : 0;
  }
}
