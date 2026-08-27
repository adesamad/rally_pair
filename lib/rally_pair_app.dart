import 'package:flutter/material.dart';

import 'play_session/store.dart';
import 'rally_pair_theme.dart';
import 'session_library/session_library_page.dart';

class RallyPairApp extends StatelessWidget {
  const RallyPairApp({super.key, required this.store});

  final PlaySessionStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '羽搭',
      debugShowCheckedModeBanner: false,
      theme: RallyPairTheme.light,
      home: SessionLibraryPage(store: store),
    );
  }
}
