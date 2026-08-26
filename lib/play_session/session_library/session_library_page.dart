import 'package:flutter/material.dart';

import '../../rally_pair_widgets/rally_pair_icon/rally_pair_icon.dart';
import '../../zf_rally_pair_app/zf_rally_pair_app.dart';
import '../session_models.dart';
import '../session_setup/session_setup_page.dart';
import '../session_store.dart';
import 'new_session_sheet.dart';

class SessionLibraryPage extends StatefulWidget {
  const SessionLibraryPage({super.key, required this.store});

  final PlaySessionStore store;

  @override
  State<SessionLibraryPage> createState() => _SessionLibraryPageState();
}

class _SessionLibraryPageState extends State<SessionLibraryPage> {
  late Stream<List<PlaySession>> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = widget.store.watchSessions();
  }

  @override
  void didUpdateWidget(covariant SessionLibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store == widget.store) return;
    _sessions = widget.store.watchSessions();
  }

  Future<void> _createSession() async {
    final id = await showNewSessionSheet(context, widget.store);
    if (!mounted || id == null) return;
    final session = await widget.store.findSession(id);
    if (!mounted) return;
    if (session == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂时无法打开新球局')));
      return;
    }
    await _openSession(session);
  }

  Future<void> _openSession(PlaySession session) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            SessionSetupPage(session: session, store: widget.store),
      ),
    );
  }

  void _retry() {
    setState(() => _sessions = widget.store.watchSessions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('羽搭', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '继续已有球局，或创建一场新的约球。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ZfRallyPairColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<PlaySession>>(
                stream: _sessions,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _LibraryError(onRetry: _retry);
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final sessions = snapshot.data!;
                  if (sessions.isEmpty) return const _EmptyLibrary();
                  return _SessionList(sessions: sessions, onOpen: _openSession);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            key: const Key('create-session'),
            onPressed: _createSession,
            icon: const ExcludeSemantics(
              child: RallyPairIcon(RallyPairIconAsset.session),
            ),
            label: const Text('创建球局'),
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ZfRallyPairColors.surface,
                shape: BoxShape.circle,
              ),
              child: const RallyPairIcon(RallyPairIconAsset.session, size: 48),
            ),
            const SizedBox(height: 22),
            Text('还没有球局', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '创建后会自动保存在本机，下次打开可以继续。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ZfRallyPairColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions, required this.onOpen});

  final List<PlaySession> sessions;
  final ValueChanged<PlaySession> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('session-library-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _SessionCard(session: session, onTap: () => onOpen(session));
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final PlaySession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: ZfRallyPairColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ZfRallyPairColors.surfaceSoft),
      ),
      child: InkWell(
        key: Key('session-card-${session.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ZfRallyPairColors.surfaceSoft.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const RallyPairIcon(RallyPairIconAsset.session),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${session.courtCount} 块场地 · ${session.status.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ZfRallyPairColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatUpdatedAt(session.updatedAt)}更新',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ZfRallyPairColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUpdatedAt(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month月$day日 $hour:$minute ';
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('暂时无法读取球局', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '本机数据没有被修改，可以稍后重试。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ZfRallyPairColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onRetry, child: const Text('重新读取')),
          ],
        ),
      ),
    );
  }
}
