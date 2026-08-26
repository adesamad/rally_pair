enum PairingPolicy {
  random('random', '完全随机'),
  fairRotation('fair_rotation', '公平轮转');

  const PairingPolicy(this.code, this.label);

  final String code;
  final String label;

  static PairingPolicy fromCode(String code) {
    return values.firstWhere((value) => value.code == code);
  }
}

enum ScorePreset {
  quick11('quick_11', '11 分一局'),
  standard21('standard_21', '21 分三局两胜');

  const ScorePreset(this.code, this.label);

  final String code;
  final String label;

  static ScorePreset fromCode(String code) {
    return values.firstWhere((value) => value.code == code);
  }
}

enum PlaySessionStatus {
  draft('draft', '草稿'),
  active('active', '进行中'),
  completed('completed', '已完成');

  const PlaySessionStatus(this.code, this.label);

  final String code;
  final String label;

  static PlaySessionStatus fromCode(String code) {
    return values.firstWhere((value) => value.code == code);
  }
}

enum SessionPlayerState {
  waiting('waiting'),
  resting('resting'),
  left('left'),
  assigned('assigned'),
  playing('playing');

  const SessionPlayerState(this.code);

  final String code;

  static SessionPlayerState fromCode(String code) {
    return values.firstWhere((value) => value.code == code);
  }
}

class PlaySession {
  const PlaySession({
    required this.id,
    required this.title,
    required this.courtCount,
    required this.pairingPolicy,
    required this.scorePreset,
    required this.avoidRecentPartner,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final int courtCount;
  final PairingPolicy pairingPolicy;
  final ScorePreset scorePreset;
  final bool avoidRecentPartner;
  final PlaySessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SessionPlayer {
  const SessionPlayer({
    required this.id,
    required this.sessionId,
    required this.displayName,
    required this.state,
    required this.queueOrder,
    required this.createdAt,
  });

  final int id;
  final int sessionId;
  final String displayName;
  final SessionPlayerState state;
  final int queueOrder;
  final DateTime createdAt;
}

class SessionDraftInput {
  const SessionDraftInput({
    required this.title,
    this.courtCount = 2,
    this.pairingPolicy = PairingPolicy.fairRotation,
    this.scorePreset = ScorePreset.standard21,
    this.avoidRecentPartner = true,
  });

  final String title;
  final int courtCount;
  final PairingPolicy pairingPolicy;
  final ScorePreset scorePreset;
  final bool avoidRecentPartner;
}

class SessionRuleException implements Exception {
  const SessionRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}
