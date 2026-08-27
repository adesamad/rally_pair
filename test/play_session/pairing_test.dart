import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  group('Pairing', () {
    test('shuffle and team choice are deterministic for the same seed', () {
      final firstShuffle = Pairing.shuffle([1, 2, 3, 4, 5, 6], 20260722);
      final secondShuffle = Pairing.shuffle([1, 2, 3, 4, 5, 6], 20260722);
      final history = <int, Set<int>>{1: {}, 2: {}, 3: {}, 4: {}};
      final first = Pairing.teams(
        players: const [1, 2, 3, 4],
        partnerHistory: history,
        avoidRecentPartner: true,
        seed: 20260722,
      );
      final second = Pairing.teams(
        players: const [1, 2, 3, 4],
        partnerHistory: history,
        avoidRecentPartner: true,
        seed: 20260722,
      );

      expect(firstShuffle, secondShuffle);
      expect(_signature(first), _signature(second));
    });

    test('avoids a prior partnership when another split is available', () {
      final plan = Pairing.teams(
        players: const [1, 2, 3, 4],
        partnerHistory: {
          1: {2},
          2: {1},
          3: {4},
          4: {3},
        },
        avoidRecentPartner: true,
        seed: 20260722,
      );

      expect(_isTeam(plan, 1, 2), isFalse);
      expect(_isTeam(plan, 3, 4), isFalse);
      expect(plan.relaxed, isFalse);
    });

    test('marks the plan relaxed when every split repeats partnerships', () {
      final plan = Pairing.teams(
        players: const [1, 2, 3, 4],
        partnerHistory: {
          1: {2, 3, 4},
          2: {1, 3, 4},
          3: {1, 2, 4},
          4: {1, 2, 3},
        },
        avoidRecentPartner: true,
        seed: 20260722,
      );

      expect(plan.relaxed, isTrue);
    });

    test('uses the input order when partnership avoidance is disabled', () {
      final plan = Pairing.teams(
        players: const [1, 2, 3, 4],
        partnerHistory: const {},
        avoidRecentPartner: false,
        seed: 20260722,
      );

      expect(plan.teamA.players, [1, 2]);
      expect(plan.teamB.players, [3, 4]);
      expect(plan.relaxed, isFalse);
    });

    test('requires four unique players', () {
      expect(
        () => Pairing.teams(
          players: const [1, 2, 2, 4],
          partnerHistory: const {},
          avoidRecentPartner: true,
          seed: 20260722,
        ),
        throwsA(
          isA<RuleViolation>().having(
            (error) => error.code,
            'code',
            'four_unique_players_required',
          ),
        ),
      );
    });
  });
}

List<List<int>> _signature(PairingPlan plan) {
  return [plan.teamA.players, plan.teamB.players];
}

bool _isTeam(PairingPlan plan, int first, int second) {
  final expected = {first, second};
  return plan.teamA.players.toSet().containsAll(expected) ||
      plan.teamB.players.toSet().containsAll(expected);
}
