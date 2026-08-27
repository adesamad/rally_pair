import 'package:flutter/material.dart';

import '../play_session/play_session.dart';
import '../rally_pair_icon.dart';
import '../rally_pair_theme.dart';
import '../session_flow/live_session_page.dart';
import '../session_flow/session_roster_page.dart';
import 'session_setup_page.dart';

class SessionLibraryPage extends StatefulWidget {
  const SessionLibraryPage({super.key, required this.store});

  final PlaySessionStore store;

  @override
  State<SessionLibraryPage> createState() => _SessionLibraryPageState();
}

class _SessionLibraryPageState extends State<SessionLibraryPage> {
  var _loading = true;
  Object? _error;
  List<PlaySession> _sessions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await widget.store.loadAll();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final setup = await Navigator.of(context).push<SessionSetup>(
      MaterialPageRoute(builder: (_) => const SessionSetupPage()),
    );
    if (!mounted || setup == null) return;

    final nextId =
        _sessions.fold<int>(
          0,
          (largest, session) => session.id > largest ? session.id : largest,
        ) +
        1;
    try {
      await widget.store.save(PlaySession.create(id: nextId, setup: setup));
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              SessionRosterPage(store: widget.store, sessionId: nextId),
        ),
      );
      if (!mounted) return;
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('球局未能保存，请重试。')));
    }
  }

  Future<void> _openSession(PlaySession session) async {
    final page = switch (session.status) {
      SessionStatus.draft => SessionRosterPage(
        store: widget.store,
        sessionId: session.id,
      ),
      SessionStatus.active => LiveSessionPage(
        store: widget.store,
        sessionId: session.id,
      ),
      SessionStatus.completed || SessionStatus.deleted => null,
    };
    if (page == null) return;
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final active = _sessions
        .where((session) => session.status == SessionStatus.active)
        .toList(growable: false);
    final other = _sessions
        .where((session) => session.status != SessionStatus.active)
        .toList(growable: false);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          key: const PageStorageKey('session-library'),
          slivers: [
            SliverToBoxAdapter(child: _LibraryHeader(onCreate: _create)),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _LoadingState(),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(onRetry: _load),
              )
            else if (_sessions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onCreate: _create),
              )
            else ...[
              if (active.isNotEmpty)
                _SessionSection(
                  title: '进行中的球局',
                  icon: RallyPairIconData.session,
                  sessions: active,
                  emphasized: true,
                  onOpen: _openSession,
                ),
              if (other.isNotEmpty)
                _SessionSection(
                  title: active.isEmpty ? '全部球局' : '其他球局',
                  icon: RallyPairIconData.history,
                  sessions: other,
                  onOpen: _openSession,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(15) > 19;
          if (constraints.maxWidth < 300 || largeText) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Brand(),
                const SizedBox(height: 16),
                FilledButton(onPressed: onCreate, child: const Text('新建球局')),
              ],
            );
          }
          return Row(
            children: [
              const Expanded(child: _Brand()),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(96, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('新建球局'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RallyPairColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RallyPairColors.outline),
          ),
          child: const RallyPairIcon(
            RallyPairIconData.session,
            semanticLabel: '球局',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('羽搭', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 2),
              const Text(
                '这台设备上的球局',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: RallyPairColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({
    required this.title,
    required this.icon,
    required this.sessions,
    required this.onOpen,
    this.emphasized = false,
  });

  final String title;
  final RallyPairIconData icon;
  final List<PlaySession> sessions;
  final ValueChanged<PlaySession> onOpen;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      sliver: SliverList.list(
        children: [
          _SectionTitle(title: title, icon: icon),
          const SizedBox(height: 12),
          for (var index = 0; index < sessions.length; index++) ...[
            _SessionCard(
              session: sessions[index],
              emphasized: emphasized,
              onTap:
                  sessions[index].status == SessionStatus.draft ||
                      sessions[index].status == SessionStatus.active
                  ? () => onOpen(sessions[index])
                  : null,
            ),
            if (index != sessions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final RallyPairIconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RallyPairIcon(icon, semanticLabel: title),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.emphasized,
    required this.onTap,
  });

  final PlaySession session;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completedMatches = session.matches
        .where((match) => match.state == MatchState.completed)
        .length;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: emphasized ? RallyPairColors.accent : RallyPairColors.outline,
          width: emphasized ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.setup.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: session.status),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetadataChip(label: '${session.players.length} 人'),
                  _MetadataChip(label: '${session.setup.courtCount} 块场地'),
                  _MetadataChip(label: '$completedMatches 场已完成'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status) {
      SessionStatus.draft => (
        '待开始',
        RallyPairColors.primary,
        RallyPairColors.surfaceSoft,
      ),
      SessionStatus.active => (
        '进行中',
        RallyPairColors.textPrimary,
        const Color(0xFFDDF4E7),
      ),
      SessionStatus.completed => (
        '已结束',
        RallyPairColors.textSecondary,
        const Color(0xFFEEF2F5),
      ),
      SessionStatus.deleted => (
        '已删除',
        RallyPairColors.danger,
        const Color(0xFFFBECEF),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: RallyPairColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: RallyPairColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RallyPairColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RallyPairColors.outline),
            ),
            child: const RallyPairIcon(
              RallyPairIconData.session,
              size: 32,
              semanticLabel: '新球局',
            ),
          ),
          const SizedBox(height: 20),
          Text('从第一场球局开始', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            '设置场地和规则后，再加入本场玩家。',
            textAlign: TextAlign.center,
            style: TextStyle(color: RallyPairColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onCreate, child: const Text('新建球局')),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('暂时无法读取球局', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            '本地数据没有被修改，可以重新读取。',
            textAlign: TextAlign.center,
            style: TextStyle(color: RallyPairColors.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: onRetry, child: const Text('重新读取')),
        ],
      ),
    );
  }
}
