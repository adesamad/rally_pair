import 'session.dart';

abstract interface class PlaySessionStore {
  Future<void> save(PlaySession session);

  Future<PlaySession?> load(int id);

  Future<List<PlaySession>> loadAll();

  Future<PlaySession?> latestActive();

  Future<PlaySession> update(int id, void Function(PlaySession session) change);

  Future<void> delete(int id);

  Future<void> replaceAll(Iterable<PlaySession> sessions);
}
