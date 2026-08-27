import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  group('ScoreRules', () {
    test('winner-only result is valid for either preset', () {
      final result = MatchResult.winnerOnly(Side.a);

      expect(
        () => ScoreRules.validate(ScorePreset.quick11, result),
        returnsNormally,
      );
      expect(
        () => ScoreRules.validate(ScorePreset.standard21, result),
        returnsNormally,
      );
    });

    test('quick 11 accepts exactly one game ending at 11', () {
      final result = MatchResult.gameScores(const [GameScore(11, 7)]);

      expect(
        () => ScoreRules.validate(ScorePreset.quick11, result),
        returnsNormally,
      );
    });

    test('quick 11 rejects extension and multiple games', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.quick11,
          MatchResult.gameScores(const [GameScore(12, 10)]),
        ),
        _throwsViolation('invalid_quick_11_score'),
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.quick11,
          MatchResult.gameScores(const [GameScore(11, 8), GameScore(11, 9)]),
        ),
        _throwsViolation('quick_11_requires_one_game'),
      );
    });

    test('standard 21 accepts straight games and a deciding game', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 15), GameScore(21, 18)]),
        ),
        returnsNormally,
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [
            GameScore(21, 18),
            GameScore(17, 21),
            GameScore(22, 20),
          ]),
        ),
        returnsNormally,
      );
    });

    test('standard 21 accepts deuce and the 30 point cap', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(22, 20), GameScore(30, 29)]),
        ),
        returnsNormally,
      );
    });

    test('standard 21 rejects illegal deuce and scores above the cap', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 20), GameScore(21, 18)]),
        ),
        _throwsViolation('invalid_standard_21_score'),
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(31, 29), GameScore(21, 18)]),
        ),
        _throwsViolation('invalid_standard_21_score'),
      );
    });

    test('standard 21 enforces best-of-three match structure', () {
      expect(
        () => MatchResult.gameScores(const [
          GameScore(21, 18),
          GameScore(18, 21),
        ]),
        _throwsViolation('winner_required'),
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [
            GameScore(21, 18),
            GameScore(21, 17),
            GameScore(18, 21),
          ]),
        ),
        _throwsViolation('standard_21_has_extra_game'),
      );
    });
  });
}

Matcher _throwsViolation(String code) {
  return throwsA(
    isA<RuleViolation>().having((error) => error.code, 'code', code),
  );
}
