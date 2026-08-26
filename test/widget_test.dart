import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_pair/main.dart';
import 'package:rally_pair/play_session/play_session.dart';
import 'package:rally_pair/rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';

void main() {
  testWidgets('创建球局、添加球员并在重新启动后继续设置', (tester) async {
    final database = FdRallyPairDatabase(NativeDatabase.memory());
    final store = PlaySessionStore(database);

    await tester.pumpWidget(RallyPairApp(store: store));
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
      '周五晚场',
    );
    await tester.tap(find.byKey(const Key('create-session-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('周五晚场'), findsOneWidget);
    expect(find.text('还没有玩家'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('player-name')),
        matching: find.byType(EditableText),
      ),
      '小林',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-player')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('小林'), findsOneWidget);

    await tester.tap(find.byKey(const Key('back-to-library')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('session-card-1')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpWidget(RallyPairApp(store: PlaySessionStore(database)));
    await tester.pump();
    expect(find.byKey(const Key('session-card-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('session-card-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.descendant(
        of: find.byType(SessionSetupPage),
        matching: find.text('周五晚场'),
      ),
      findsOneWidget,
    );
    expect(find.text('小林'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}
