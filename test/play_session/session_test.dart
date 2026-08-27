import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';

void main() {
  group('持续双人组', () {
    test('随机组队保留奇数未成组玩家', () {
      final session = _draft(5);

      final groups = session.generateRandomGroups();

      expect(groups, hasLength(2));
      expect(session.groups, hasLength(2));
      expect(
        session.players.where((p) => p.state == PlayerState.ungrouped),
        hasLength(1),
      );
      expect(groups.expand((group) => group.players).toSet(), hasLength(4));
    });

    test('手动组队不能重复占用同一玩家', () {
      final session = _draft(4);
      session.createManualGroup(1, 2);

      expect(
        () => session.createManualGroup(1, 3),
        throwsA(isA<RuleViolation>()),
      );
    });

    test('候场组支持随机和指定位置排序', () {
      final session = _draft(8)..generateRandomGroups();
      final last = session.waitingGroups.last.id;

      session.reorderGroup(last, 0);
      expect(session.waitingGroups.first.id, last);

      final before = session.waitingGroups.map((group) => group.id).toSet();
      session.randomizeGroupQueue();
      expect(session.waitingGroups.map((group) => group.id).toSet(), before);
    });

    test('可编辑并解散指定的非首等待组', () {
      final session = _draft(7)..generateRandomGroups();
      final target = session.waitingGroups[1];
      final originalOrder = target.queueOrder;
      final source = target.firstPlayerId;
      final replacement = session.players
          .firstWhere((player) => player.state == PlayerState.ungrouped)
          .id;

      session.updateGroup(
        groupId: target.id,
        sourcePlayerId: source,
        replacementPlayerId: replacement,
      );

      final updated = session.groups.firstWhere(
        (group) => group.id == target.id,
      );
      expect(updated.queueOrder, originalOrder);
      expect(updated.contains(replacement), isTrue);
      expect(
        session.players.firstWhere((player) => player.id == source).state,
        PlayerState.ungrouped,
      );

      session.dissolveGroup(target.id);
      expect(
        session.groups.firstWhere((group) => group.id == target.id).state,
        GroupState.dissolved,
      );
    });
  });

  group('场地比赛与轮转', () {
    test('胜方留场会直接承接既有候场组', () {
      final session = _active(8);
      final first = session.assignNextGroups(1);
      final loserId = first.groupBId;

      session.startMatch(first.id);
      session.finishMatch(first.id, MatchResult.winnerOnly(Side.a));
      expect(session.courts.single.state, CourtState.awaitingRotation);

      session.resolveWinnerStays(first.id);

      final next = session.matches.last;
      expect(next.state, MatchState.ready);
      expect(next.groupAId, first.groupAId);
      expect(next.groupBId, isNot(loserId));
      expect(session.courts.single.state, CourtState.ready);
    });

    test('两组下场不会让刚下场组立即重赛', () {
      final session = _active(8);
      final first = session.assignNextGroups(1);
      final departed = {first.groupAId, first.groupBId};

      session.startMatch(first.id);
      session.finishMatch(first.id, MatchResult.winnerOnly(Side.b));
      session.resolveAllRotate(first.id);

      final next = session.matches.last;
      expect({next.groupAId, next.groupBId}.intersection(departed), isEmpty);
      expect(first.state, MatchState.ready);
      expect(session.matches.first.state, MatchState.completed);
    });

    test('胜方无对手时留场，并可释放回队尾', () {
      final session = _active(4);
      final match = session.assignNextGroups(1);
      session.startMatch(match.id);
      session.finishMatch(match.id, MatchResult.winnerOnly(Side.a));

      session.resolveWinnerStays(match.id);
      expect(session.courts.single.state, CourtState.waitingOpponent);
      expect(session.waitingGroups, hasLength(1));

      session.releaseStayingCourt(1);
      expect(session.courts.single.state, CourtState.available);
      expect(session.waitingGroups, hasLength(2));
    });

    test('无效比分不能进入待轮转', () {
      final session = _active(4);
      final match = session.assignNextGroups(1);
      session.startMatch(match.id);

      expect(
        () => session.finishMatch(
          match.id,
          MatchResult.gameScores(const [GameScore(21, 20), GameScore(21, 18)]),
        ),
        throwsA(isA<RuleViolation>()),
      );
      expect(session.matches.single.state, MatchState.inProgress);
      expect(session.courts.single.state, CourtState.inPlay);
    });

    test('可把指定的非首两组安排到指定非首场地', () {
      final session = PlaySession.create(
        id: 2,
        setup: const SessionSetup(
          title: '指定安排',
          courtCount: 0,
          scorePreset: ScorePreset.standard21,
          randomSeed: 8,
        ),
      );
      session.addCourt('东场');
      final west = session.addCourt('西场');
      for (var index = 1; index <= 8; index++) {
        session.addPlayer('指定$index');
      }
      session.generateRandomGroups();
      session.start();
      final selected = session.waitingGroups.skip(1).take(2).toList();

      final match = session.assignGroups(
        courtNumber: west.number,
        firstGroupId: selected[0].id,
        secondGroupId: selected[1].id,
      );

      expect(match.courtNumber, west.number);
      expect(
        {match.groupAId, match.groupBId},
        {selected[0].id, selected[1].id},
      );
      expect(session.courts.first.state, CourtState.available);
    });

    test('结束后复制只保留设置、具名场地和玩家名单', () {
      final session = PlaySession.create(
        id: 3,
        setup: const SessionSetup(
          title: '原球局',
          courtCount: 0,
          scorePreset: ScorePreset.quick11,
          randomSeed: 11,
        ),
      );
      session.addCourt('靠窗场');
      session.addCourt('中间场');
      for (var index = 1; index <= 4; index++) {
        session.addPlayer('复制$index');
      }
      session.generateRandomGroups();
      session.start();
      session.complete();

      final duplicate = session.duplicate(id: 4, title: '新球局');

      expect(duplicate.status, SessionStatus.draft);
      expect(duplicate.courts.map((court) => court.name), ['靠窗场', '中间场']);
      expect(duplicate.players, hasLength(4));
      expect(duplicate.groups, isEmpty);
      expect(duplicate.matches, isEmpty);
    });
  });
}

PlaySession _draft(int players) {
  final session = PlaySession.create(
    id: 1,
    setup: const SessionSetup(
      title: '周末球局',
      courtCount: 1,
      scorePreset: ScorePreset.standard21,
      randomSeed: 20260722,
    ),
  );
  for (var index = 1; index <= players; index++) {
    session.addPlayer('玩家$index');
  }
  return session;
}

PlaySession _active(int players) {
  final session = _draft(players)..generateRandomGroups();
  session.start();
  return session;
}
