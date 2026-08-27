import 'package:flutter/material.dart';

import 'rally_pair_app.dart';
import 'rally_pair_helper/fd_rally_pair_db/fd_play_session_store.dart';
import 'rally_pair_helper/fd_rally_pair_db/fd_rally_pair_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = FdRallyPairDatabase();
  runApp(RallyPairApp(store: FdPlaySessionStore(database)));
}
