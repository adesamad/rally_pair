import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_app.dart';

void main() {
  testWidgets('创建球局后进入玩家名单并可添加玩家', (tester) async {
    final store = _MemoryStore();
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('从第一场球局开始'), findsOneWidget);
    await tester.tap(find.text('新建球局').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '周六晚场');
    await tester.tap(find.text('创建球局'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.setup.title, '周六晚场');
    expect(find.text('准备本场玩家'), findsOneWidget);
    expect(find.text('周六晚场'), findsOneWidget);
    expect(find.text('还需 4 名玩家'), findsOneWidget);

    await tester.tap(find.text('添加玩家'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '小林');
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.players.single.name, '小林');
    expect(find.text('还需 3 名玩家'), findsOneWidget);
  });

  testWidgets('读取失败后可以重试', (tester) async {
    final store = _MemoryStore(failFirstLoad: true);
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('暂时无法读取球局'), findsOneWidget);
    await tester.tap(find.text('重新读取'));
    await tester.pumpAndSettle();

    expect(find.text('从第一场球局开始'), findsOneWidget);
    expect(store.loadCount, 2);
  });

  testWidgets('球局状态同时使用文字和视觉标记', (tester) async {
    final active = PlaySession.create(id: 1, setup: _setup('单位训练'));
    active
      ..addPlayer('甲')
      ..addPlayer('乙')
      ..addPlayer('丙')
      ..addPlayer('丁')
      ..start();
    final store = _MemoryStore()..sessions.add(active);

    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('进行中的球局'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);
    expect(find.text('4 人'), findsOneWidget);
  });

  testWidgets('草稿可以批量添加四人并启动现场球局', (tester) async {
    final draft = PlaySession.create(id: 1, setup: _setup('周中训练'));
    final store = _MemoryStore()..sessions.add(draft);
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('周中训练'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('批量添加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '甲\n乙\n丙\n丁');
    await tester.tap(find.text('加入名单'));
    await tester.pumpAndSettle();

    expect(find.text('启动球局'), findsOneWidget);
    await tester.tap(find.text('启动球局'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.status, SessionStatus.active);
    expect(find.text('现场球场'), findsOneWidget);
    expect(find.text('球场'), findsOneWidget);
    expect(find.text('结果'), findsOneWidget);
  });

  testWidgets('玩家名单支持改名和确认移除', (tester) async {
    final draft = PlaySession.create(id: 1, setup: _setup('名单调整'))
      ..addPlayer('旧名字');
    final store = _MemoryStore()..sessions.add(draft);
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('名单调整'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('改名'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '新名字');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.players.single.name, '新名字');
    await tester.tap(find.text('移除'));
    await tester.pumpAndSettle();
    expect(find.text('移除玩家？'), findsOneWidget);
    await tester.tap(find.text('确认移除'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.players, isEmpty);
    expect(find.text('名单还是空的'), findsOneWidget);
  });

  testWidgets('现场球局可以生成分组开赛并录入胜方', (tester) async {
    final active = PlaySession.create(id: 1, setup: _setup('完整流程'))
      ..addPlayer('甲')
      ..addPlayer('乙')
      ..addPlayer('丙')
      ..addPlayer('丁')
      ..start();
    final store = _MemoryStore()..sessions.add(active);
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('完整流程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('分组'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生成分组'));
    await tester.pumpAndSettle();

    expect(store.sessions.single.matches.single.state, MatchState.ready);
    await tester.tap(find.text('球场'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始比赛'));
    await tester.pumpAndSettle();
    expect(store.sessions.single.matches.single.state, MatchState.inProgress);

    await tester.tap(find.text('录入胜方'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A 组获胜'));
    await tester.pumpAndSettle();
    expect(store.sessions.single.matches.single.state, MatchState.completed);

    await tester.tap(find.text('结果'));
    await tester.pumpAndSettle();
    expect(find.text('A 组获胜'), findsOneWidget);
  });

  testWidgets('现场球局在窄屏和放大文字下保持可操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final active = PlaySession.create(id: 1, setup: _setup('窄屏球局'))
      ..addPlayer('甲')
      ..addPlayer('乙')
      ..addPlayer('丙')
      ..addPlayer('丁')
      ..start();
    final store = _MemoryStore()..sessions.add(active);
    await tester.pumpWidget(RallyPairApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('窄屏球局'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('候场'));
    await tester.pumpAndSettle();
    expect(find.text('玩家状态'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

SessionSetup _setup(String title) {
  return SessionSetup(
    title: title,
    courtCount: 2,
    pairingPolicy: PairingPolicy.fairRotation,
    scorePreset: ScorePreset.standard21,
    avoidRecentPartner: true,
    randomSeed: 7,
  );
}

class _MemoryStore implements PlaySessionStore {
  _MemoryStore({this.failFirstLoad = false});

  final bool failFirstLoad;
  final sessions = <PlaySession>[];
  var loadCount = 0;

  @override
  Future<void> save(PlaySession session) async {
    sessions.removeWhere((value) => value.id == session.id);
    sessions.add(session);
  }

  @override
  Future<List<PlaySession>> loadAll() async {
    loadCount++;
    if (failFirstLoad && loadCount == 1) throw StateError('load failed');
    return List.unmodifiable(sessions);
  }

  @override
  Future<PlaySession?> load(int id) async {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  @override
  Future<PlaySession?> latestActive() async {
    for (final session in sessions.reversed) {
      if (session.status == SessionStatus.active) return session;
    }
    return null;
  }

  @override
  Future<PlaySession> update(
    int id,
    void Function(PlaySession session) change,
  ) async {
    final session = await load(id);
    if (session == null) throw const RuleViolation('session_not_found');
    change(session);
    return session;
  }

  @override
  Future<void> delete(int id) async {
    sessions.removeWhere((session) => session.id == id);
  }
}
