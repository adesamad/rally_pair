import 'models.dart';

final class ScoreRules {
  const ScoreRules._();

  static void validate(ScorePreset preset, MatchResult result) {
    if (result.mode == ResultMode.winnerOnly) return;
    switch (preset) {
      case ScorePreset.quick11:
        _quick11(result);
      case ScorePreset.standard21:
        _standard21(result);
    }
  }

  static void _quick11(MatchResult result) {
    if (result.games.length != 1) {
      throw const RuleViolation('quick_11_requires_one_game');
    }
    final game = result.games.single;
    final high = game.a > game.b ? game.a : game.b;
    final low = game.a < game.b ? game.a : game.b;
    if (high != 11 || low < 0 || low >= 11) {
      throw const RuleViolation('invalid_quick_11_score');
    }
  }

  static void _standard21(MatchResult result) {
    final games = result.games;
    if (games.length < 2 || games.length > 3) {
      throw const RuleViolation('standard_21_requires_two_or_three_games');
    }
    for (final game in games) {
      if (!_validStandardGame(game)) {
        throw const RuleViolation('invalid_standard_21_score');
      }
    }

    final firstTwoWinner = games[0].winner == games[1].winner;
    if (games.length == 2 && !firstTwoWinner) {
      throw const RuleViolation('standard_21_requires_deciding_game');
    }
    if (games.length == 3 && firstTwoWinner) {
      throw const RuleViolation('standard_21_has_extra_game');
    }
  }

  static bool _validStandardGame(GameScore game) {
    if (game.a < 0 || game.b < 0 || game.a == game.b) return false;
    final high = game.a > game.b ? game.a : game.b;
    final low = game.a < game.b ? game.a : game.b;
    if (high == 21) return low <= 19;
    if (high >= 22 && high <= 29) return high - low == 2;
    if (high == 30) return low == 28 || low == 29;
    return false;
  }
}
