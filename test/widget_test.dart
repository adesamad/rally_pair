import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_icon.dart';
import 'package:rally_pair/rally_pair_theme.dart';
import 'package:rally_pair/session_library/session_library_page.dart';
import 'package:rally_pair/session_library/session_setup_page.dart';
import 'package:rally_pair/session_flow/live_session_page.dart';
import 'package:rally_pair/session_flow/session_roster_page.dart';

void main() {
  testWidgets('新建球局可选择单打并固定为单场地单局', (tester) async {
    SessionSetup? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await Navigator.of(context).push<SessionSetup>(
                MaterialPageRoute(builder: (_) => const SessionSetupPage()),
              );
            },
            child: const Text('打开新建'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开新建'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '周四单打练习');
    await tester.tap(find.text('单打 · 2 人'));
    await tester.tap(find.text('创建球局'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.matchFormat, MatchFormat.singles);
    expect(result!.courtCount, 1);
    expect(result!.singleGame, isTrue);
  });

  testWidgets('准备页提供随机和手动组队，并按双人组启用开局', (tester) async {
    final session = _draft(4)..generateRandomGroups();
    final store = _MemoryStore(session);

    await tester.pumpWidget(
      MaterialApp(home: SessionRosterPage(store: store, sessionId: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('random-groups')), findsOneWidget);
    expect(find.byKey(const ValueKey('manual-group')), findsOneWidget);
    expect(find.byKey(const ValueKey('session-readiness')), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('启动双打球局'), findsOneWidget);
    expect(find.textContaining('玩家'), findsWidgets);
  });

  testWidgets('单打准备页按个人候场且不显示组队入口', (tester) async {
    final session = PlaySession.create(
      id: 1,
      setup: const SessionSetup(
        title: '单打练习',
        courtCount: 1,
        matchFormat: MatchFormat.singles,
        scorePreset: ScorePreset.standard21,
        randomSeed: 20260830,
      ),
    );
    for (var index = 1; index <= 2; index++) {
      session.addPlayer('球友$index');
    }

    await tester.pumpWidget(
      MaterialApp(
        home: SessionRosterPage(
          store: _MemoryStore(session),
          sessionId: session.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('random-groups')), findsNothing);
    expect(find.byKey(const ValueKey('manual-group')), findsNothing);
    expect(find.text('启动单打球局'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('现场页用具象球场显示两侧四人和比赛动作', (tester) async {
    final session = _draft(4)..generateRandomGroups();
    session.start();
    final match = session.assignNextGroups(1);
    session.startMatch(match.id);
    final store = _MemoryStore(session);

    await tester.pumpWidget(
      MaterialApp(home: LiveSessionPage(store: store, sessionId: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey('court-surface-${match.id}')), findsOneWidget);
    for (var index = 1; index <= 4; index++) {
      expect(find.text('玩家$index'), findsOneWidget);
    }
    expect(find.text('录入胜方'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('单打现场球场只显示两名对手并保留个人候场', (tester) async {
    final session = PlaySession.create(
      id: 2,
      setup: const SessionSetup(
        title: '单打现场',
        courtCount: 1,
        matchFormat: MatchFormat.singles,
        scorePreset: ScorePreset.standard21,
        randomSeed: 2,
      ),
    );
    for (var index = 1; index <= 4; index++) {
      session.addPlayer('单打$index');
    }
    session.start();
    final match = session.assignNext(1);

    await tester.pumpWidget(
      MaterialApp(
        home: LiveSessionPage(store: _MemoryStore(session), sessionId: 2),
      ),
    );
    await tester.pumpAndSettle();

    final court = find.byKey(ValueKey('court-surface-${match.id}'));
    expect(
      find.descendant(of: court, matching: find.text('单打1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: court, matching: find.text('单打2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: court, matching: find.text('单打3')),
      findsNothing,
    );
    await tester.tap(find.text('球友'));
    await tester.pumpAndSettle();
    expect(find.text('候场 · 2'), findsOneWidget);
    expect(find.text('单打3'), findsOneWidget);
    expect(find.text('单打4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('窄屏放大文字下具象球场不溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = _draft(4)..generateRandomGroups();
    session.start();
    session.assignNextGroups(1);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(
          home: LiveSessionPage(store: _MemoryStore(session), sessionId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('court-surface-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('球场姓名标签保持紧凑并留出主要场线', (tester) async {
    final session = _draft(4)..generateRandomGroups();
    session.start();
    final match = session.assignNextGroups(1);

    await tester.pumpWidget(
      MaterialApp(
        home: LiveSessionPage(store: _MemoryStore(session), sessionId: 1),
      ),
    );
    await tester.pumpAndSettle();

    final courtSize = tester.getSize(
      find.byKey(ValueKey('court-surface-${match.id}')),
    );
    final labelSize = tester.getSize(
      find
          .ancestor(
            of: find.text('玩家1'),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );

    expect(labelSize.width / courtSize.width, lessThanOrEqualTo(.28));
    expect(labelSize.height / courtSize.height, lessThanOrEqualTo(.2));
  });

  testWidgets('球场主操作图标适配按钮且比分不覆盖场地', (tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = _draft(8);
    session.addCourt('2 号场');
    session.generateRandomGroups();
    session.start();
    final inPlay = session.assignNextGroups(1);
    session.startMatch(inPlay.id);
    final recorded = session.assignNextGroups(2);
    session.startMatch(recorded.id);
    session.finishMatch(
      recorded.id,
      MatchResult.gameScores(const [GameScore(21, 17)]),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          theme: RallyPairTheme.light,
          home: LiveSessionPage(store: _MemoryStore(session), sessionId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(ValueKey('court-surface-${recorded.id}')),
        matching: find.textContaining('21:17'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(ValueKey('match-result-summary-${recorded.id}')),
      findsOneWidget,
    );
    final actionIcons = tester.widgetList<RallyPairIcon>(
      find.byType(RallyPairIcon),
    );
    expect(
      actionIcons
          .where(
            (icon) =>
                icon.data == RallyPairIconData.scoreEntry ||
                icon.data == RallyPairIconData.rotation,
          )
          .map((icon) => icon.size),
      everyElement(18),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('现场工作台可直接安排场地并继续组队', (tester) async {
    final session = _draft(6)..generateRandomGroups();
    session.start();
    session.addPlayer('临时甲');
    session.addPlayer('临时乙');

    await tester.pumpWidget(
      MaterialApp(
        home: LiveSessionPage(store: _MemoryStore(session), sessionId: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('live-next-action')), findsOneWidget);
    expect(find.text('现场'), findsOneWidget);
    expect(find.text('球友'), findsOneWidget);
    expect(find.text('记录'), findsOneWidget);
    expect(find.byKey(const ValueKey('assign-next-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('assign-specific-1')), findsOneWidget);

    await tester.tap(find.text('球友'));
    await tester.pumpAndSettle();

    expect(find.text('随机组队'), findsOneWidget);
    expect(find.text('手动组队'), findsOneWidget);
    expect(find.byKey(const ValueKey('complete-session')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('空闲球场安排后立即显示开赛动作', (tester) async {
    final session = _draft(8)..generateRandomGroups();
    session.start();
    final store = _MemoryStore(session);

    await tester.pumpWidget(
      MaterialApp(home: LiveSessionPage(store: store, sessionId: 1)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('live-next-action-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('start-match-1')), findsOneWidget);
    expect(find.textContaining('已排好对阵'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('只有一组候场时空闲球场不提供自动安排', (tester) async {
    final session = _draft(4);
    session.addCourt('2 号场');
    session.generateRandomGroups();
    session.start();
    session.assignNextGroups(1);
    session.addPlayer('候补甲');
    session.addPlayer('候补乙');
    session.createManualGroup(5, 6);

    await tester.pumpWidget(
      MaterialApp(
        home: LiveSessionPage(store: _MemoryStore(session), sessionId: 1),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    final assignButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('assign-next-2')),
    );
    expect(assignButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('已结束球局可进入总结查看统计和比赛记录', (tester) async {
    final session = _draft(4)..generateRandomGroups();
    session.start();
    final match = session.assignNextGroups(1);
    session.startMatch(match.id);
    session.finishMatch(
      match.id,
      MatchResult.gameScores(const [GameScore(21, 17)]),
    );
    session.resolveAllRotate(match.id);
    session.complete();

    await tester.pumpWidget(
      MaterialApp(home: SessionLibraryPage(store: _MemoryStore(session))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('完整流程'));
    await tester.pumpAndSettle();

    expect(find.text('本场总结'), findsOneWidget);
    expect(find.text('球友表现'), findsOneWidget);
    expect(find.text('比赛记录'), findsOneWidget);
    expect(find.text('1 场'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Debug 测试按钮写入八个单场地单双打状态样本', (tester) async {
    final store = _MemoryStore(_draft(4));

    await tester.pumpWidget(
      MaterialApp(home: SessionLibraryPage(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('debug-reset-data')));
    await tester.pumpAndSettle();
    expect(find.text('清除并加入测试数据？'), findsOneWidget);
    expect(find.textContaining('此操作无法撤销'), findsOneWidget);

    await tester.tap(find.text('清除并生成'));
    await tester.pumpAndSettle();

    final sessions = await store.loadAll();
    expect(sessions.map((session) => session.id), [
      91001,
      91002,
      91003,
      91004,
      91005,
      91006,
      91007,
      91008,
    ]);
    expect(sessions.map((session) => session.status), [
      SessionStatus.draft,
      SessionStatus.draft,
      SessionStatus.active,
      SessionStatus.active,
      SessionStatus.active,
      SessionStatus.active,
      SessionStatus.completed,
      SessionStatus.completed,
    ]);
    expect(sessions.map((session) => session.courts.single.state), [
      CourtState.available,
      CourtState.available,
      CourtState.ready,
      CourtState.inPlay,
      CourtState.awaitingRotation,
      CourtState.waitingOpponent,
      CourtState.available,
      CourtState.available,
    ]);
    expect(sessions.map((session) => session.setup.matchFormat), [
      MatchFormat.singles,
      MatchFormat.doubles,
      MatchFormat.doubles,
      MatchFormat.singles,
      MatchFormat.doubles,
      MatchFormat.singles,
      MatchFormat.singles,
      MatchFormat.doubles,
    ]);
    expect(sessions[1].players.map((player) => player.name), contains('徐子墨'));
    expect(sessions[1].waitingGroups, hasLength(3));
    expect(
      sessions[1].players.where(
        (player) => player.state == PlayerState.ungrouped,
      ),
      hasLength(1),
    );
    expect(sessions.every((session) => session.courts.length == 1), isTrue);
    expect(
      sessions[6].matches.where((match) => match.state == MatchState.completed),
      hasLength(4),
    );
    expect(
      sessions[7].matches.where((match) => match.state == MatchState.completed),
      hasLength(4),
    );
    expect(
      sessions
          .expand((session) => session.matches)
          .where((match) => match.result?.mode == ResultMode.gameScores)
          .every((match) => match.result!.games.length == 1),
      isTrue,
    );
    expect(
      sessions
          .expand((session) => session.players)
          .map((player) => player.name),
      everyElement(allOf(isNot(startsWith('测试玩家')), isNot(startsWith('历史玩家')))),
    );
    expect(tester.takeException(), isNull);
  });
}

PlaySession _draft(int count) {
  final session = PlaySession.create(
    id: 1,
    setup: const SessionSetup(
      title: '完整流程',
      courtCount: 1,
      scorePreset: ScorePreset.standard21,
      randomSeed: 20260722,
    ),
  );
  for (var index = 1; index <= count; index++) {
    session.addPlayer('玩家$index');
  }
  return session;
}

class _MemoryStore implements PlaySessionStore {
  _MemoryStore(PlaySession session)
    : _sessions = {session.id: PlaySession.restore(session.snapshot())};

  final Map<int, PlaySession> _sessions;

  @override
  Future<void> save(PlaySession session) async {
    _sessions[session.id] = PlaySession.restore(session.snapshot());
  }

  @override
  Future<PlaySession?> load(int id) async {
    final session = _sessions[id];
    return session == null ? null : PlaySession.restore(session.snapshot());
  }

  @override
  Future<List<PlaySession>> loadAll() async {
    return [
      for (final session in _sessions.values)
        PlaySession.restore(session.snapshot()),
    ];
  }

  @override
  Future<PlaySession?> latestActive() async {
    for (final session in _sessions.values.toList().reversed) {
      if (session.status == SessionStatus.active) {
        return PlaySession.restore(session.snapshot());
      }
    }
    return null;
  }

  @override
  Future<PlaySession> update(
    int id,
    void Function(PlaySession session) change,
  ) async {
    final session = _sessions[id];
    if (session == null) throw const RuleViolation('session_not_found');
    final copy = PlaySession.restore(session.snapshot());
    change(copy);
    _sessions[id] = copy;
    return PlaySession.restore(copy.snapshot());
  }

  @override
  Future<void> delete(int id) async => _sessions.remove(id);

  @override
  Future<void> replaceAll(Iterable<PlaySession> sessions) async {
    final replacements = {
      for (final session in sessions)
        session.id: PlaySession.restore(session.snapshot()),
    };
    _sessions
      ..clear()
      ..addAll(replacements);
  }
}
