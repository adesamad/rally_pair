import 'package:flutter/material.dart';

import 'play_session/play_session.dart';
import 'rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';
import 'zf_rally_pair_app/zf_rally_pair_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = FdRallyPairDatabase();
  runApp(RallyPairApp(store: PlaySessionStore(database)));
}

class RallyPairApp extends StatelessWidget {
  const RallyPairApp({super.key, required this.store});

  final PlaySessionStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ZfRallyPairAppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ZfRallyPairTheme.light,
      home: SessionLibraryPage(store: store),
    );
  }
}
