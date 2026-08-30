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

    test('standard 21 accepts exactly one game', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 15)]),
        ),
        returnsNormally,
      );
    });

    test('standard 21 accepts deuce and the 30 point cap', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(22, 20)]),
        ),
        returnsNormally,
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(30, 29)]),
        ),
        returnsNormally,
      );
    });

    test('standard 21 rejects illegal deuce and scores above the cap', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 20)]),
        ),
        _throwsViolation('invalid_standard_21_score'),
      );
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(31, 29)]),
        ),
        _throwsViolation('invalid_standard_21_score'),
      );
    });

    test('standard 21 rejects multiple games for new sessions', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 18), GameScore(21, 17)]),
        ),
        _throwsViolation('standard_21_requires_one_game'),
      );
    });

    test('legacy standard 21 series remains readable', () {
      expect(
        () => ScoreRules.validate(
          ScorePreset.standard21,
          MatchResult.gameScores(const [GameScore(21, 18), GameScore(21, 17)]),
          allowLegacySeries: true,
        ),
        returnsNormally,
      );
    });
  });
}

Matcher _throwsViolation(String code) {
  return throwsA(
    isA<RuleViolation>().having((error) => error.code, 'code', code),
  );
}
