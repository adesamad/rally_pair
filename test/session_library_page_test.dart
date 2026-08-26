import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';
import 'package:rally_pair/zf_rally_pair_app/zf_rally_pair_app.dart';

void main() {
  late FdRallyPairDatabase database;
  late PlaySessionStore store;
  var databaseClosed = false;

  setUp(() {
    database = FdRallyPairDatabase(NativeDatabase.memory());
    store = PlaySessionStore(database);
    databaseClosed = false;
  });

  tearDown(() async {
    if (!databaseClosed) await database.close();
  });

  testWidgets('creates a draft from the empty library', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ZfRallyPairTheme.light,
        home: SessionLibraryPage(store: store),
      ),
    );
    await tester.pump();

    expect(find.text('还没有球局'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-session')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('new-session-title')),
        matching: find.byType(EditableText),
      ),
      '周三晚场',
    );
    await tester.tap(find.byKey(const Key('create-session-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('周三晚场'), findsOneWidget);
    expect(find.byKey(const Key('back-to-library')), findsOneWidget);
    expect(find.textContaining('2 块', findRichText: true), findsOneWidget);
    final stored = await database.select(database.fdRallyPairSessions).get();
    expect(stored, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
    databaseClosed = true;
  });

  testWidgets('keeps the create sheet open when the title is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ZfRallyPairTheme.light,
        home: SessionLibraryPage(store: store),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('create-session')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('create-session-submit')));
    await tester.pump();

    expect(find.byKey(const Key('new-session-error')), findsOneWidget);
    expect(find.text('请输入球局名称'), findsOneWidget);
    final stored = await database.select(database.fdRallyPairSessions).get();
    expect(stored, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
    databaseClosed = true;
  });
}
