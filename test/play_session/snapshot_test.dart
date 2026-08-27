import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  test('snapshot 恢复双人组、队列和场地状态', () {
    final session = _session();
    final match = session.assignNextGroups(1);
    session.startMatch(match.id);
    session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));

    final restored = PlaySession.restore(session.snapshot());

    expect(restored.groups, hasLength(3));
    expect(restored.waitingGroups, hasLength(1));
    expect(restored.courts.single.state, CourtState.awaitingRotation);
    expect(restored.matches.single.state, MatchState.resultRecorded);
  });

  test('snapshot 拒绝重复 group identity', () {
    final session = _session();
    final snapshot = session.snapshot();

    expect(
      () => PlaySession.restore(
        PlaySessionSnapshot(
          id: snapshot.id,
          setup: snapshot.setup,
          status: snapshot.status,
          players: snapshot.players,
          groups: [snapshot.groups.first, snapshot.groups.first],
          courts: snapshot.courts,
          matches: snapshot.matches,
          nextPlayerId: snapshot.nextPlayerId,
          nextGroupId: snapshot.nextGroupId,
          nextMatchId: snapshot.nextMatchId,
          nextQueueOrder: snapshot.nextQueueOrder,
          pairingRound: snapshot.pairingRound,
          completionOrder: snapshot.completionOrder,
        ),
      ),
      throwsA(isA<RuleViolation>()),
    );
  });

  test('旧版进行中快照会补建固定组并迁移场地状态', () {
    final restored = PlaySession.restore(
      PlaySessionSnapshot(
        id: 9,
        setup: const SessionSetup(
          title: '旧版活动',
          courtCount: 1,
          scorePreset: ScorePreset.standard21,
          randomSeed: 3,
        ),
        status: SessionStatus.active,
        players: const [
          SessionPlayer(
            id: 1,
            name: '甲',
            state: PlayerState.assigned,
            queueOrder: 0,
          ),
          SessionPlayer(
            id: 2,
            name: '乙',
            state: PlayerState.assigned,
            queueOrder: 1,
          ),
          SessionPlayer(
            id: 3,
            name: '丙',
            state: PlayerState.assigned,
            queueOrder: 2,
          ),
          SessionPlayer(
            id: 4,
            name: '丁',
            state: PlayerState.assigned,
            queueOrder: 3,
          ),
          SessionPlayer(
            id: 5,
            name: '候补',
            state: PlayerState.waiting,
            queueOrder: 4,
          ),
        ],
        courts: const [
          Court(number: 1, state: CourtState.reserved, matchId: 1),
        ],
        matches: const [
          SessionMatch(
            id: 1,
            courtNumber: 1,
            teamA: Team(1, 2),
            teamB: Team(3, 4),
            state: MatchState.ready,
            relaxed: false,
          ),
        ],
        nextPlayerId: 6,
        nextMatchId: 2,
        nextQueueOrder: 5,
        pairingRound: 0,
        completionOrder: 0,
      ),
    );

    expect(restored.groups, hasLength(2));
    expect(restored.matches.single.groupAId, isNotNull);
    expect(restored.matches.single.groupBId, isNotNull);
    expect(restored.courts.single.state, CourtState.ready);
    expect(restored.players.last.state, PlayerState.ungrouped);
  });
}

PlaySession _session() {
  final session = PlaySession.create(
    id: 1,
    setup: const SessionSetup(
      title: '恢复测试',
      courtCount: 1,
      scorePreset: ScorePreset.standard21,
      randomSeed: 7,
    ),
  );
  for (var index = 1; index <= 6; index++) {
    session.addPlayer('玩家$index');
  }
  session.generateRandomGroups();
  session.start();
  return session;
}
