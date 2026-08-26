import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';
import 'package:rally_pair/zf_rally_pair_app/zf_rally_pair_app.dart';

void main() {
  late FdRallyPairDatabase database;
  late PlaySessionStore store;
  late PlaySession session;
  var databaseClosed = false;

  setUp(() async {
    database = FdRallyPairDatabase(NativeDatabase.memory());
    store = PlaySessionStore(database);
    final id = await store.createSession(
      const SessionDraftInput(
        title: '周末晨练',
        courtCount: 3,
        pairingPolicy: PairingPolicy.random,
        scorePreset: ScorePreset.quick11,
        avoidRecentPartner: false,
      ),
    );
    session = (await store.findSession(id))!;
    databaseClosed = false;
  });

  tearDown(() async {
    if (!databaseClosed) await database.close();
  });

  Future<void> disposePage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
    databaseClosed = true;
  }

  testWidgets('shows setup and adds a player', (tester) async {
    await _pumpPage(tester, session, store);

    expect(find.textContaining('3 块', findRichText: true), findsOneWidget);
    expect(find.textContaining('完全随机', findRichText: true), findsOneWidget);
    expect(find.textContaining('11 分一局', findRichText: true), findsOneWidget);
    expect(find.text('还差 4 人可组成一场双打'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('player-name')),
        matching: find.byType(EditableText),
      ),
      '林一',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-player')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();

    final stored = await database.select(database.fdRallyPairPlayers).get();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
    await tester.pump();
    expect(find.text('林一'), findsOneWidget);
    expect(find.text('还差 3 人可组成一场双打'), findsOneWidget);
    expect(stored, hasLength(1));

    await disposePage(tester);
  });

  testWidgets('requires confirmation before removing a player', (tester) async {
    final playerId = await store.addPlayer(session.id, '陈二');
    await _pumpPage(tester, session, store);

    await tester.tap(find.byKey(Key('remove-player-$playerId')));
    await tester.pumpAndSettle();
    expect(find.text('移除陈二？'), findsOneWidget);

    await tester.tap(find.text('保留'));
    await tester.pumpAndSettle();
    expect(find.text('陈二'), findsOneWidget);

    await tester.tap(find.byKey(Key('remove-player-$playerId')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认移除'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('陈二'), findsNothing);
    final stored = await database.select(database.fdRallyPairPlayers).get();
    expect(stored, isEmpty);

    await disposePage(tester);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  PlaySession session,
  PlaySessionStore store,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ZfRallyPairTheme.light,
      home: SessionSetupPage(session: session, store: store),
    ),
  );
  await tester.pump();
}
