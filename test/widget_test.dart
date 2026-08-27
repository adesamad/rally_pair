import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/session_library/session_library_page.dart';
import 'package:rally_pair/session_flow/live_session_page.dart';
import 'package:rally_pair/session_flow/session_roster_page.dart';

void main() {
  testWidgets('准备页提供随机和手动组队，并按双人组启用开局', (tester) async {
    final session = _draft(4)..generateRandomGroups();
    final store = _MemoryStore(session);

    await tester.pumpWidget(
      MaterialApp(home: SessionRosterPage(store: store, sessionId: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('random-groups')), findsOneWidget);
    expect(find.byKey(const ValueKey('manual-group')), findsOneWidget);
    expect(find.text('启动球局'), findsOneWidget);
    expect(find.textContaining('玩家'), findsWidgets);
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

  testWidgets('现场分组页可继续组队并手动指定场地与两组', (tester) async {
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
    await tester.tap(find.text('分组'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('assign-specific-groups')),
      220,
    );

    expect(find.text('随机组队'), findsOneWidget);
    expect(find.text('手动组队'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('assign-specific-groups')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('complete-session')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Debug 测试按钮清空旧球局并写入三种状态数据', (tester) async {
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
    expect(sessions.map((session) => session.id), [91001, 91002, 91003]);
    expect(sessions.map((session) => session.status), [
      SessionStatus.active,
      SessionStatus.draft,
      SessionStatus.completed,
    ]);
    expect(
      sessions.first.courts.map((court) => court.state),
      containsAll([CourtState.inPlay, CourtState.awaitingRotation]),
    );
    expect(find.text('Debug · 现场轮转'), findsOneWidget);
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
