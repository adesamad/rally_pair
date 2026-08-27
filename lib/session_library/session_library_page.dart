import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> _duplicateSession(PlaySession session) async {
    final controller = TextEditingController(
      text: '${session.setup.title} · 再来一场',
    );
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('复制为新球局'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '新球局名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(dialogContext).pop(value);
            },
            child: const Text('创建副本'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || title == null) return;
    final nextId =
        _sessions.fold<int>(
          0,
          (largest, value) => value.id > largest ? value.id : largest,
        ) +
        1;
    try {
      final duplicate = session.duplicate(
        id: nextId,
        title: title,
        randomSeed: DateTime.now().microsecondsSinceEpoch,
      );
      await widget.store.save(duplicate);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              SessionRosterPage(store: widget.store, sessionId: nextId),
        ),
      );
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('副本未能创建，本地原球局没有变化。')));
    }
  }

  Future<void> _deleteSession(PlaySession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除球局？'),
        content: Text('“${session.setup.title}”及其本地比赛记录将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RallyPairColors.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await widget.store.delete(session.id);
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('删除失败，球局数据仍然保留。')));
    }
  }

  Future<void> _resetDebugData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除并加入测试数据？'),
        content: const Text(
          '这会永久删除当前设备内的全部球局数据，并写入 3 个 Debug 球局：进行中、待准备和已结束。此操作无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RallyPairColors.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('清除并生成'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    Object? failure;
    try {
      await widget.store.replaceAll(_debugSessions());
    } catch (error) {
      failure = error;
    }
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failure == null ? '测试数据已生成，可以直接进入不同状态的球局。' : '测试数据重置未完整完成，请再次尝试。',
        ),
      ),
    );
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
            SliverToBoxAdapter(
              child: _LibraryHeader(
                busy: _loading,
                onCreate: _create,
                onResetDebugData: _resetDebugData,
              ),
            ),
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
                  onDuplicate: _duplicateSession,
                  onDelete: _deleteSession,
                ),
              if (other.isNotEmpty)
                _SessionSection(
                  title: active.isEmpty ? '全部球局' : '其他球局',
                  icon: RallyPairIconData.history,
                  sessions: other,
                  onOpen: _openSession,
                  onDuplicate: _duplicateSession,
                  onDelete: _deleteSession,
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
  const _LibraryHeader({
    required this.busy,
    required this.onCreate,
    required this.onResetDebugData,
  });

  final bool busy;
  final VoidCallback onCreate;
  final VoidCallback onResetDebugData;

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
                if (kDebugMode) ...[
                  OutlinedButton(
                    key: const ValueKey('debug-reset-data'),
                    onPressed: busy ? null : onResetDebugData,
                    child: const Text('重置测试数据'),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton(
                  onPressed: busy ? null : onCreate,
                  child: const Text('新建球局'),
                ),
              ],
            );
          }
          return Row(
            children: [
              const Expanded(child: _Brand()),
              const SizedBox(width: 12),
              if (kDebugMode) ...[
                OutlinedButton(
                  key: const ValueKey('debug-reset-data'),
                  onPressed: busy ? null : onResetDebugData,
                  child: const Text('测试数据'),
                ),
                const SizedBox(width: 10),
              ],
              FilledButton(
                onPressed: busy ? null : onCreate,
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

List<PlaySession> _debugSessions() {
  final active = PlaySession.create(
    id: 91001,
    setup: const SessionSetup(
      title: 'Debug · 现场轮转',
      courtCount: 0,
      scorePreset: ScorePreset.standard21,
      randomSeed: 91001,
      defaultRotationMode: RotationMode.winnerStays,
    ),
  );
  active.addCourt('东侧 1 号场');
  active.addCourt('西侧 2 号场');
  const activeNames = [
    '林远',
    '周然',
    '陈川',
    '许安',
    '唐晓',
    '吴桐',
    '顾宁',
    '江禾',
    '沈悦',
    '韩松',
    '苏晴',
    '陆洋',
  ];
  for (final name in activeNames) {
    active.addPlayer(name);
  }
  for (var id = 1; id <= activeNames.length; id += 2) {
    active.createManualGroup(id, id + 1);
  }
  active.start();
  final playing = active.assignNextGroups(1);
  active.startMatch(playing.id);
  final awaitingRotation = active.assignNextGroups(2);
  active.startMatch(awaitingRotation.id);
  active.finishMatch(
    awaitingRotation.id,
    MatchResult.gameScores(const [
      GameScore(21, 18),
      GameScore(19, 21),
      GameScore(21, 16),
    ]),
  );

  final draft = PlaySession.create(
    id: 91002,
    setup: const SessionSetup(
      title: 'Debug · 待准备名单',
      courtCount: 0,
      scorePreset: ScorePreset.quick11,
      randomSeed: 91002,
      defaultRotationMode: RotationMode.allRotate,
    ),
  );
  draft.addCourt('靠窗场');
  draft.addCourt('中间场');
  for (var index = 1; index <= 8; index++) {
    draft.addPlayer('测试玩家 $index');
  }
  draft.createManualGroup(1, 2);
  draft.createManualGroup(3, 4);

  final completed = PlaySession.create(
    id: 91003,
    setup: const SessionSetup(
      title: 'Debug · 已结束历史',
      courtCount: 1,
      scorePreset: ScorePreset.standard21,
      randomSeed: 91003,
      defaultRotationMode: RotationMode.allRotate,
    ),
  );
  for (var index = 1; index <= 4; index++) {
    completed.addPlayer('历史玩家 $index');
  }
  completed.createManualGroup(1, 2);
  completed.createManualGroup(3, 4);
  completed.start();
  final historical = completed.assignNextGroups(1);
  completed.startMatch(historical.id);
  completed.finishMatch(
    historical.id,
    MatchResult.gameScores(const [GameScore(21, 15), GameScore(21, 17)]),
  );
  completed.resolveAllRotate(historical.id);
  completed.complete();

  return [active, draft, completed];
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
    required this.onDuplicate,
    required this.onDelete,
    this.emphasized = false,
  });

  final String title;
  final RallyPairIconData icon;
  final List<PlaySession> sessions;
  final ValueChanged<PlaySession> onOpen;
  final ValueChanged<PlaySession> onDuplicate;
  final ValueChanged<PlaySession> onDelete;
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
              onDuplicate:
                  sessions[index].status == SessionStatus.active ||
                      sessions[index].status == SessionStatus.completed
                  ? () => onDuplicate(sessions[index])
                  : null,
              onDelete: () => onDelete(sessions[index]),
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
    required this.onDuplicate,
    required this.onDelete,
  });

  final PlaySession session;
  final bool emphasized;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback onDelete;

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
                  PopupMenuButton<String>(
                    tooltip: '球局操作',
                    onSelected: (value) {
                      if (value == 'duplicate') onDuplicate?.call();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      if (onDuplicate != null)
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Text('再次组织'),
                        ),
                      const PopupMenuItem(value: 'delete', child: Text('删除球局')),
                    ],
                  ),
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
